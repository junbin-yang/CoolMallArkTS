import { BaseViewModel } from "base";
import { OrderCacheStoreRepository } from "data";
import { Cart, CartGoodsSpec, SelectedGoods } from "model";

/**
 * @file 订单确认页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class OrderConfirmViewModel extends BaseViewModel {
  /**
   * 订单缓存本地存储仓库
   */
  private readonly orderCacheStoreRepository: OrderCacheStoreRepository = new OrderCacheStoreRepository();
  /**
   * 从购物车来的商品项（仅购物车页面会存储）
   */
  cachedCarts: Cart[] | null = null;
  /**
   * 选中的商品列表（从缓存中获取）
   */
  @Trace
  selectedGoodsList: SelectedGoods[] = [];
  /**
   * 购物车列表（用于页面展示）
   * 优先从 cachedCarts 获取，没有则从 selectedGoodsList 转换
   */
  @Trace
  cartList: Cart[] = [];

  /**
   * 页面出现时加载数据
   * @returns {void} 无返回值
   */
  aboutToAppear(): void {
    super.aboutToAppear();
    this.loadOrderCache();
  }

  /**
   * 从缓存加载订单数据
   * @returns {Promise<void>} Promise<void>
   */
  async loadOrderCache(): Promise<void> {
    // 1. 读取购物车缓存（仅购物车页面会存储）
    this.cachedCarts = await this.orderCacheStoreRepository.loadCarts();

    // 2. 读取已选商品列表
    this.selectedGoodsList = await this.orderCacheStoreRepository.loadSelectedGoodsList() ?? [];

    // 3. 购物车列表：优先从 cachedCarts 获取，没有则从 selectedGoodsList 转换
    if (this.cachedCarts && this.cachedCarts.length > 0) {
      this.cartList = this.cachedCarts;
    } else {
      this.cartList = this.convertSelectedGoodsToCartList(this.selectedGoodsList);
    }

    // 4. 清除缓存，避免重复使用
    await this.orderCacheStoreRepository.clearAll();
  }

  /**
   * 将已选商品列表转换为购物车列表
   * @param {SelectedGoods[]} goodsList 已选商品列表
   * @returns {Cart[]} 购物车列表
   */
  private convertSelectedGoodsToCartList(goodsList: SelectedGoods[]): Cart[] {
    // 按商品ID分组
    const groupedMap = new Map<number, SelectedGoods[]>();

    for (const goods of goodsList) {
      const existingList = groupedMap.get(goods.goodsId);
      if (existingList) {
        existingList.push(goods);
      } else {
        groupedMap.set(goods.goodsId, [goods]);
      }
    }

    // 为每个商品ID创建一个Cart对象
    const result: Cart[] = [];

    groupedMap.forEach((items: SelectedGoods[], goodsId: number) => {
      const firstItem = items[0];

      const cart = new Cart();
      cart.goodsId = goodsId;
      cart.goodsName = firstItem.goodsInfo?.title ?? "";
      cart.goodsMainPic = firstItem.goodsInfo?.mainPic ?? "";

      // 收集该商品的所有规格
      const allSpecs: CartGoodsSpec[] = [];

      for (const selectedItem of items) {
        // 如果有规格信息，转换为CartGoodsSpec并添加
        if (selectedItem.spec) {
          const cartSpec = new CartGoodsSpec();
          cartSpec.id = selectedItem.spec.id;
          cartSpec.goodsId = selectedItem.spec.goodsId;
          cartSpec.name = selectedItem.spec.name;
          cartSpec.price = selectedItem.spec.price;
          cartSpec.stock = selectedItem.spec.stock;
          cartSpec.count = selectedItem.count;
          cartSpec.images = selectedItem.spec.images;
          allSpecs.push(cartSpec);
        }
      }

      cart.spec = allSpecs;
      result.push(cart);
    });

    return result;
  }

  /**
   * 是否从购物车来的
   * @returns {boolean} 是否从购物车来
   */
  get isFromCart(): boolean {
    return this.cachedCarts !== null && this.cachedCarts.length > 0;
  }

  /**
   * 购物车是否为空
   * @returns {boolean} 是否为空
   */
  get isEmpty(): boolean {
    return this.cartList.length === 0;
  }
}
