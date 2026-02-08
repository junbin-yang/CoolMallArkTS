import { ColumnStart, P100, SpaceVerticalMedium } from "designsystem";
import { Coupon } from "model";
import { CouponCard, CouponCardMode } from "../coupon/CouponCard";
import { BottomModal } from "./BottomModal";

/**
 * @file 优惠券领取弹窗组件
 * @author Joker.X
 */
@ComponentV2
export struct CouponReceiveModal {
  /**
   * 是否显示弹窗
   */
  @Param
  @Require
  visible: boolean = false;
  /**
   * 弹窗标题
   */
  @Param
  title: ResourceStr = $r("app.string.coupon_modal_title");
  /**
   * 优惠券列表
   */
  @Param
  coupons: Coupon[] = [];
  /**
   * 优惠券卡片模式
   */
  @Param
  mode: CouponCardMode = CouponCardMode.RECEIVE;
  /**
   * 关闭回调
   */
  @Param
  onDismiss: () => void = () => {
  };
  /**
   * 优惠券操作回调
   */
  @Param
  onCouponAction: (couponId: number) => void = () => {
  };

  /**
   * 构建优惠券领取弹窗
   * @returns {void} 无返回值
   */
  build(): void {
    BottomModal({
      visible: this.visible,
      title: this.title,
      onDismiss: this.onDismiss,
      containerColor: $r("app.color.bg_grey"),
      content: (): void => this.ModalContent()
    });
  }

  /**
   * 构建弹窗内容
   * @returns {void} 无返回值
   */
  @Builder
  private ModalContent(): void {
    ColumnStart({ widthValue: P100 }) {
      Scroll() {
        ColumnStart({ widthValue: P100 }) {
          ForEach(this.coupons, (coupon: Coupon, index: number): void => {
            CouponCard({
              coupon,
              mode: this.mode,
              onActionClick: (): void => this.onCouponAction(coupon.id)
            });
            if (index !== this.coupons.length - 1) {
              SpaceVerticalMedium();
            }
          }, (coupon: Coupon, index: number): string => `${coupon.id}-${index}`);
        }
      }
      .width(P100)
      .constraintSize({ maxHeight: 500 })
      .scrollBar(BarState.Off);
    }
  }
}
