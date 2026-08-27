enum ProductCategory {
  all('전체'),
  auction('경매'),
  used('중고거래'),
  realEstate('부동산'),
  partTimeJob('알바');

  const ProductCategory(this.label);

  final String label;
}
