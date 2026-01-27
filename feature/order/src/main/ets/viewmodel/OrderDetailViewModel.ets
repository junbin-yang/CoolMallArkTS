import { BaseNetWorkViewModel } from "base";
import { OrderRepository } from "data";
import { Cart, CartGoodsSpec, NetworkResponse, Order, OrderGoods } from "model";
import { GoodsNavigator, OrderIdParam, OrderNavigator, getRouteParams } from "navigation";
import { OrderRoutes } from "navigation/src/main/ets/order/OrderRoutes";

/**
 * @file 订单详情页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class OrderDetailViewModel extends BaseNetWorkViewModel<Order> {
  /**
   * 订单仓库
   */
  private readonly repository: OrderRepository = new OrderRepository();
  /**
   * 路由参数
   */
  private readonly routeParam: OrderIdParam | undefined = getRouteParams<OrderIdParam>(OrderRoutes.Detail);
  /**
   * 订单 ID
   */
  private readonly orderId: number = this.routeParam?.orderId ?? 0;
  /**
   * 订单商品列表（购物车结构）
   */
  @Trace
  cartList: Cart[] = [];

  /**
   * 请求订单详情数据
   * @returns {Promise<NetworkResponse<Order>>} 网络请求 Promise
   */
  protected requestRepository(): Promise<NetworkResponse<Order>> {
    return this.repository.getOrderInfo(this.orderId);
  }

  /**
   * 请求成功回调
   * @param {Order} data - 订单数据
   * @returns {void} 无返回值
   */
  protected onRequestSuccess(data: Order): void {
    this.cartList = this.convertOrderGoodsToCart(data);
    super.onRequestSuccess(data);
  }

  /**
   * 跳转支付页面
   * @returns {void} 无返回值
   */
  toPay(): void {
    const order: Order = this.data ?? new Order();
    const payPrice: number = order.price - order.discountPrice;
    OrderNavigator.toPay(order.id, payPrice);
  }

  /**
   * 跳转订单评价页面
   * @returns {void} 无返回值
   */
  toComment(): void {
    const order: Order = this.data ?? new Order();
    const goodsId: number = this.getFirstGoodsId(order);
    if (!goodsId) {
      return;
    }
    OrderNavigator.toComment(order.id, goodsId);
  }

  /**
   * 跳转商品详情页面（再次购买）
   * @returns {void} 无返回值
   */
  toGoodsDetail(): void {
    const order: Order = this.data ?? new Order();
    const goodsId: number = this.getFirstGoodsId(order);
    if (!goodsId) {
      return;
    }
    GoodsNavigator.toDetail(goodsId);
  }

  /**
   * 将订单商品转换为购物车列表
   * @param {Order} order - 订单信息
   * @returns {Cart[]} 购物车列表
   */
  private convertOrderGoodsToCart(order: Order): Cart[] {
    const goodsList: OrderGoods[] = order.goodsList ?? [];
    if (goodsList.length === 0) {
      return [];
    }

    const groupedMap = new Map<number, OrderGoods[]>();
    for (const goods of goodsList) {
      const exists = groupedMap.get(goods.goodsId);
      if (exists) {
        exists.push(goods);
      } else {
        groupedMap.set(goods.goodsId, [goods]);
      }
    }

    const result: Cart[] = [];
    groupedMap.forEach((items: OrderGoods[], goodsId: number): void => {
      const firstItem: OrderGoods = items[0];
      const cart = new Cart();
      cart.goodsId = goodsId;
      cart.goodsName = firstItem.goodsInfo?.title ?? "";
      cart.goodsMainPic = firstItem.goodsInfo?.mainPic ?? "";

      const specs: CartGoodsSpec[] = [];
      for (const orderGoods of items) {
        if (orderGoods.spec) {
          const spec = new CartGoodsSpec();
          spec.id = orderGoods.spec.id;
          spec.goodsId = orderGoods.spec.goodsId;
          spec.name = orderGoods.spec.name;
          spec.price = orderGoods.spec.price;
          spec.stock = orderGoods.spec.stock;
          spec.count = orderGoods.count;
          spec.images = orderGoods.spec.images;
          specs.push(spec);
        }
      }

      cart.spec = specs;
      result.push(cart);
    });

    return result;
  }

  /**
   * 获取订单第一件商品 ID
   * @param {Order} order - 订单信息
   * @returns {number} 商品 ID
   */
  private getFirstGoodsId(order: Order): number {
    const goods: OrderGoods | undefined = order.goodsList?.[0];
    return goods?.goodsId ?? 0;
  }
}
