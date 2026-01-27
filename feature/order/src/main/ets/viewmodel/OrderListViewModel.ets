import { BaseNetWorkListViewModel } from "base";
import { OrderRepository } from "data";
import { Order, OrderGoods, OrderPageRequest, NetworkPageData, NetworkResponse } from "model";
import { GoodsNavigator, OrderNavigator } from "navigation";

/**
 * @file 订单列表页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class OrderListViewModel extends BaseNetWorkListViewModel<Order> {
  /**
   * 订单仓库
   */
  private readonly repository: OrderRepository = new OrderRepository();

  /**
   * 请求订单分页数据（暂时拉取全部状态）
   * @returns {Promise<NetworkResponse<NetworkPageData<Order>>>} 网络请求 Promise
   */
  protected requestListData(): Promise<NetworkResponse<NetworkPageData<Order>>> {
    const request: OrderPageRequest = new OrderPageRequest();
    request.page = this.currentPage;
    request.size = this.pageSize;
    return this.repository.getOrderPage(request);
  }

  /**
   * 跳转订单支付
   * @param {Order} order - 订单信息
   * @returns {void} 无返回值
   */
  toPay(order: Order): void {
    const payPrice: number = order.price - order.discountPrice;
    OrderNavigator.toPay(order.id, payPrice);
  }

  /**
   * 跳转商品详情（再次购买）
   * @param {Order} order - 订单信息
   * @returns {void} 无返回值
   */
  toGoodsDetail(order: Order): void {
    const goodsId: number = this.getFirstGoodsId(order);
    if (!goodsId) {
      return;
    }
    GoodsNavigator.toDetail(goodsId);
  }

  /**
   * 跳转订单评价
   * @param {Order} order - 订单信息
   * @returns {void} 无返回值
   */
  toComment(order: Order): void {
    const goodsId: number = this.getFirstGoodsId(order);
    if (!goodsId) {
      return;
    }
    OrderNavigator.toComment(order.id, goodsId);
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
