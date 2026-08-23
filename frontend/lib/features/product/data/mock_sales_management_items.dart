import '../models/sales_management_filter.dart';
import '../models/sales_management_item.dart';

const mockSalesManagementItems = [
  SalesManagementItem(
    id: 3,
    filter: SalesManagementFilter.auction,
    auction: true,
    title: '아이패드 프로 11인치',
    location: '송도동',
    timeLabel: '경매 진행 중',
    price: 420000,
    auctionRemainingTime: Duration(minutes: 12, seconds: 34),
    bidCount: 8,
  ),
  SalesManagementItem(
    id: 4,
    filter: SalesManagementFilter.completed,
    auction: true,
    title: '맥북 에어 M2',
    location: '송도동',
    timeLabel: '낙찰 완료',
    price: 980000,
    bidCount: 16,
  ),
  SalesManagementItem(
    id: 1,
    filter: SalesManagementFilter.selling,
    title: '아디다스 집업',
    location: '전국',
    timeLabel: '3개월 전',
    price: 30000,
    viewCount: 100,
    chatCount: 3,
  ),
  SalesManagementItem(
    id: 2,
    filter: SalesManagementFilter.completed,
    title: 'LG 노트북',
    location: '전국',
    timeLabel: '10개월 전',
    price: 250000,
    viewCount: 77,
    chatCount: 3,
  ),
];
