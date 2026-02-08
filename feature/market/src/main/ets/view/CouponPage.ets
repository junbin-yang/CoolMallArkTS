import { P100 } from "designsystem";
import { Coupon } from "model";
import { AppNavDestination, BaseNetWorkListView, CouponCard, CouponCardMode, RefreshLayout } from "ui";
import CouponViewModel from "../viewmodel/CouponViewModel";

/**
 * @file 优惠券页面视图
 * @author Joker.X
 */
@ComponentV2
export struct CouponPage {
  /**
   * 优惠券页面 ViewModel
   */
  @Local
  private vm: CouponViewModel = new CouponViewModel();
  /**
   * 列表滚动控制器
   */
  private listScroller: Scroller = new Scroller();

  /**
   * 构建优惠券页面
   * @returns {void} 无返回值
   */
  build(): void {
    AppNavDestination({
      title: $r("app.string.coupon_title"),
      viewModel: this.vm
    }) {
      BaseNetWorkListView({
        uiState: this.vm.uiState,
        onRetry: (): void => this.vm.retryRequest(),
        content: (): void => this.CouponContent()
      });
    }
  }

  /**
   * 优惠券页面内容视图
   * @returns {void} 无返回值
   */
  @Builder
  private CouponContent(): void {
    RefreshLayout({
      loading: this.vm.isLoading,
      isEnableSlideUp: this.vm.isEnableSlideUp,
      scroller: this.listScroller,
      onRefresh: (direction: "pull" | "slideUp"): void => this.vm.onRefreshDirection(direction)
    }) {
      List({ space: 12, scroller: this.listScroller }) {
        ForEach(this.vm.listData, (item: Coupon): void => {
          ListItem() {
            CouponCard({
              coupon: item,
              mode: CouponCardMode.VIEW,
              onActionClick: (): void => this.vm.navigateToGoodsCategory(item)
            });
          }
        }, (item: Coupon): string => `${item.id}`);
      }
      .padding($r("app.float.space_padding_medium"))
      .edgeEffect(EdgeEffect.None)
      .width(P100)
      .height(P100);
    }
  }
}
