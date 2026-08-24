import 'package:frontend/features/auction/models/auction_create_form.dart';
import 'package:frontend/features/auction/models/auction_detail.dart';
import 'package:frontend/features/auction/models/auction_page.dart';
import 'package:frontend/features/auction/models/auction_preview.dart';
import 'package:frontend/features/auction/models/auction_update_message.dart';
import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_exception.dart';
import 'package:http/http.dart' as http;

abstract interface class AuctionGateway {
  Future<AuctionUpdateMessage> placeBid(int auctionId, int amount);

  Future<int> createAuction(AuctionCreateForm form);

  Future<AuctionPage> listAuctions({int offset = 0, int limit = 20});

  Future<AuctionDetail> getAuctionDetail(int auctionId);

  Future<void> cancelAuction(int auctionId);

  Future<void> completeTrade(int auctionId);
}

class AuctionApi implements AuctionGateway {
  AuctionApi(this._client, this._tokenStorage);

  final ApiClient _client;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuctionUpdateMessage> placeBid(int auctionId, int amount) async {
    final accessToken = await _requireAccessToken();

    final json = await _client.post(
      '/auctions/$auctionId/bids',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'amount': amount},
    );
    return AuctionUpdateMessage.fromJson(json);
  }

  @override
  Future<int> createAuction(AuctionCreateForm form) async {
    final String accessToken;
    try {
      accessToken = await _requireAccessToken();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        statusCode: 0,
        code: 'TOKEN_READ_FAILED',
        message: '로그인 정보를 읽지 못했어요. 다시 로그인해 주세요.',
      );
    }

    // 모든 플랫폼에서 XFile의 바이트를 읽어 동일한 multipart 요청으로 전송한다.
    final List<http.MultipartFile> files;
    try {
      files = await Future.wait(
        form.imageFiles.map(
          (image) async => http.MultipartFile.fromBytes(
            'images',
            await image.readAsBytes(),
            filename: image.name,
          ),
        ),
      );
    } catch (_) {
      throw const ApiException(
        statusCode: 0,
        code: 'IMAGE_READ_FAILED',
        message: '선택한 사진을 읽지 못했어요. 사진을 다시 선택해 주세요.',
      );
    }

    final json = await _client.postMultipart(
      '/products/auctions',
      headers: {'Authorization': 'Bearer $accessToken'},
      fields: {
        'category_id': '${form.categoryId}',
        'title': form.title,
        'description': form.description,
        'start_price': '${form.startingPrice}',
        'minimum_bid_unit': '${form.bidIncrement}',
        // 서버가 실행 지역과 무관하게 같은 순간을 해석하도록 UTC ISO 문자열로 전송
        'starts_at': form.startsAt.toUtc().toIso8601String(),
        'ends_at': form.endsAt.toUtc().toIso8601String(),
        'extension_count': '${form.extensionCount}',
      },
      files: files,
    );
    return json['id'] as int;
  }

  @override
  Future<AuctionPage> listAuctions({int offset = 0, int limit = 20}) async {
    final json = await _client.get('/auctions?offset=$offset&limit=$limit');
    final rawItems = json['items'] as List<dynamic>;
    return AuctionPage(
      items: auctionsWithEndedLast(
        rawItems.map(
          (item) => AuctionPreview.fromJson(item as Map<String, dynamic>),
        ),
      ),
      total: (json['total'] as num?)?.toInt() ?? rawItems.length,
      nextOffset:
          ((json['offset'] as num?)?.toInt() ?? offset) + rawItems.length,
    );
  }

  @override
  Future<AuctionDetail> getAuctionDetail(int auctionId) async {
    final json = await _client.get('/auctions/$auctionId');
    return AuctionDetail.fromJson(json);
  }

  @override
  Future<void> cancelAuction(int auctionId) async {
    final accessToken = await _requireAccessToken();
    await _client.patch(
      '/auctions/$auctionId/cancel',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  @override
  Future<void> completeTrade(int auctionId) async {
    final accessToken = await _requireAccessToken();
    await _client.patch(
      '/auctions/$auctionId/trade-complete',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<String> _requireAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        statusCode: 401,
        code: 'ACCESS_TOKEN_NOT_FOUND',
        message: '로그인이 필요합니다.',
      );
    }
    return accessToken;
  }
}
