import { BaseNetWorkListViewModel } from "base";
import { CouponRepository } from "data";
import { Coupon, NetworkPageData, NetworkResponse, PageRequest } from "model";
import { GoodsNavigator } from "navigation";
import { GoodsCategoryParam } from "navigation/src/main/ets/goods/GoodsParam";

/**
 * @file 优惠券页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class CouponViewModel extends BaseNetWorkListViewModel<Coupon> {
  /**
   * 优惠券仓库
   */
  private readonly couponRepository: CouponRepository = new CouponRepository();

  /**
   * 请求优惠券分页数据
   * @returns {Promise<NetworkResponse<NetworkPageData<Coupon>>>} 网络请求 Promise
   */
  protected requestListData(): Promise<NetworkResponse<NetworkPageData<Coupon>>> {
    const request: PageRequest = new PageRequest();
    request.page = this.currentPage;
    request.size = this.pageSize;
    return this.couponRepository.getUserCouponPage(request);
  }

  /**
   * 跳转到商品分类页面并带上最低金额
   * @param {Coupon} coupon - 当前优惠券
   * @returns {void} 无返回值
   */
  navigateToGoodsCategory(coupon: Coupon): void {
    const minPrice: string = coupon.condition?.fullAmount?.toString() ?? "";
    const params: GoodsCategoryParam = {
      minPrice
    };
    GoodsNavigator.toCategory(params);
  }
}
