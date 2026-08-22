import 'package:frontend/features/auction/models/auction_create_form.dart';
import 'package:frontend/features/auction/models/auction_detail.dart';
import 'package:frontend/features/auction/models/auction_preview.dart';
import 'package:frontend/features/auction/models/auction_update_message.dart';
import 'package:frontend/features/auth/services/auth_token_storage.dart';
import 'package:frontend/shared/network/api_client.dart';
import 'package:frontend/shared/network/api_exception.dart';
import 'package:http/http.dart' as http;

abstract interface class AuctionGateway {
  Future<AuctionUpdateMessage> placeBid(int auctionId, int amount);

  Future<int> createAuction(AuctionCreateForm form);

  Future<List<AuctionPreview>> listAuctions();

  Future<AuctionDetail> getAuctionDetail(int auctionId);
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
    final accessToken = await _requireAccessToken();
    final files = await Future.wait(
      form.imagePaths.map(
        (path) => http.MultipartFile.fromPath('images', path),
      ),
    );

    final json = await _client.postMultipart(
      '/products/auctions',
      headers: {'Authorization': 'Bearer $accessToken'},
      fields: {
        'category_id': '${form.categoryId}',
        'title': form.title,
        'description': form.description,
        'start_price': '${form.startingPrice}',
        'minimum_bid_unit': '${form.bidIncrement}',
        'starts_at': form.startsAt.toIso8601String(),
        'ends_at': form.endsAt.toIso8601String(),
        'extension_count': '${form.extensionCount}',
      },
      files: files,
    );
    return json['id'] as int;
  }

  @override
  Future<List<AuctionPreview>> listAuctions() async {
    final json = await _client.get('/auctions');
    final items = json['items'] as List<dynamic>;
    return items
        .map((item) => AuctionPreview.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AuctionDetail> getAuctionDetail(int auctionId) async {
    final json = await _client.get('/auctions/$auctionId');
    return AuctionDetail.fromJson(json);
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
