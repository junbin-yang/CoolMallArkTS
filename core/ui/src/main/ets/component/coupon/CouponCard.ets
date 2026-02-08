import { IBestButton, IBestDivider, IBestPrice } from "ibestui";
import { Coupon } from "model";
import { P100, SpaceHorizontalMedium, SpaceHorizontalXSmall, SpaceVerticalXSmall } from "designsystem";
import { Card } from "../card/Card";
import { CommonIcon } from "../icon/CommonIcon";
import { CouponCardMode, CouponStatus } from "./CouponCardEnum";

export { CouponCardMode } from "./CouponCardEnum";

/**
 * @file 优惠券卡片组件
 * @author Joker.X
 */
@ComponentV2
export struct CouponCard {
  /**
   * 优惠券数据
   */
  @Param
  @Require
  coupon: Coupon = new Coupon();
  /**
   * 卡片模式
   */
  @Param
  mode: CouponCardMode = CouponCardMode.RECEIVE;
  /**
   * 是否已选择
   */
  @Param
  isSelected: boolean = false;
  /**
   * 当前金额（用于选择模式判断是否可用）
   */
  @Param
  currentPrice: number | null = null;
  /**
   * 操作按钮点击回调
   */
  @Param
  onActionClick: () => void = (): void => {
  };
  /**
   * 是否展示说明区域
   */
  @Param
  showDescription: boolean = true;
  /**
   * 是否支持展开说明
   */
  @Param
  expandable: boolean = true;
  /**
   * 是否展开说明
   */
  @Local
  private isExpanded: boolean = false;

  /**
   * 构建优惠券卡片
   * @returns {void} 无返回值
   */
  build(): void {
    Column() {
      Card() {
        this.CouponMainContent();
      }
    }
    .width(P100)
    .opacity(this.isUnavailable(this.getCouponStatus()) ? 0.6 : 1);
  }

  /**
   * 构建优惠券主体内容
   * @returns {void} 无返回值
   */
  @Builder
  private CouponMainContent(): void {
    Column() {
      this.CouponTopSection();

      if (this.showDescription || this.expandable) {
        IBestDivider();
        this.CouponBottomSection();
      }
    }
    .width(P100);
  }

  /**
   * 构建优惠券顶部区域
   * @returns {void} 无返回值
   */
  @Builder
  private CouponTopSection(): void {
    Row() {
      this.CouponIcon();

      SpaceHorizontalMedium();

      this.CouponInfoSection();

      SpaceHorizontalMedium();

      this.CouponPriceSection();
    }
    .width(P100)
    .padding($r("app.float.space_padding_medium"))
    .alignItems(VerticalAlign.Center);
  }

  /**
   * 构建优惠券图标
   * @returns {void} 无返回值
   */
  @Builder
  private CouponIcon(): void {
    Row() {
      CommonIcon({
        icon: $r("app.media.ic_coupon"),
        iconSize: 24,
        tintColor: $r("app.color.bg_white")
      });
    }
    .width(46)
    .height(46)
    .borderRadius($r("app.float.radius_small"))
    .backgroundColor($r("app.color.primary"))
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center);
  }

  /**
   * 构建优惠券信息区域
   * @returns {void} 无返回值
   */
  @Builder
  private CouponInfoSection(): void {
    Column() {
      Text(this.coupon.title)
        .fontSize($r("app.float.body_large"))
        .fontWeight(FontWeight.Medium)
        .fontColor($r("app.color.text_primary"))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width(P100)
        .textAlign(TextAlign.Start);

      if (this.hasText(this.coupon.endTime)) {
        SpaceVerticalXSmall();
        Text($r("app.string.coupon_valid_until", this.coupon.endTime))
          .fontSize($r("app.float.body_medium"))
          .fontColor($r("app.color.text_tertiary"))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(P100)
          .textAlign(TextAlign.Start);
      }
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start);
  }

  /**
   * 构建优惠券金额区域
   * @returns {void} 无返回值
   */
  @Builder
  private CouponPriceSection(): void {
    Column() {
      IBestPrice({
        value: this.coupon.amount,
      });

      if (this.coupon.condition) {
        SpaceVerticalXSmall();
        Text($r("app.string.coupon_conditions", Math.floor(this.coupon.condition.fullAmount ?? 0)))
          .fontSize($r("app.float.body_medium"))
          .fontColor($r("app.color.text_secondary"))
          .maxLines(1);
      }
    }
    .alignItems(HorizontalAlign.End);
  }

  /**
   * 构建优惠券底部区域
   * @returns {void} 无返回值
   */
  @Builder
  private CouponBottomSection(): void {
    Row() {
      this.CouponDescription();
      this.CouponAction();
    }
    .width(P100)
    .padding($r("app.float.space_padding_medium"))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center);
  }

  /**
   * 构建优惠券描述区域
   * @returns {void} 无返回值
   */
  @Builder
  private CouponDescription(): void {
    Column() {
      if (this.expandable && this.hasText(this.coupon.description)) {
        Row() {
          Text($r("app.string.coupon_usage_instructions"))
            .fontSize($r("app.float.body_medium"))
            .fontColor($r("app.color.text_tertiary"));

          SpaceHorizontalXSmall();

          CommonIcon({
            icon: this.isExpanded ? $r("app.media.ic_up") : $r("app.media.ic_down"),
            iconSize: 16,
            tintColor: $r("app.color.text_tertiary")
          });
        }
        .onClick((): void => {
          this.isExpanded = !this.isExpanded;
        });

        if (this.isExpanded) {
          SpaceVerticalXSmall();
          Text(this.coupon.description)
            .fontSize($r("app.float.body_medium"))
            .fontColor($r("app.color.text_tertiary"))
            .textAlign(TextAlign.Start);
        }
      } else if (this.showDescription && this.hasText(this.coupon.description)) {
        Text(this.coupon.description)
          .fontSize($r("app.float.body_medium"))
          .fontColor($r("app.color.text_tertiary"))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start);
      }
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start);
  }

  /**
   * 构建优惠券操作区
   * @returns {void} 无返回值
   */
  @Builder
  private CouponAction(): void {
    if (this.getCouponStatus() === CouponStatus.AVAILABLE) {
      IBestButton({
        text: this.getAvailableActionText(),
        type: "primary",
        round: true,
        plain: this.mode === CouponCardMode.SELECT,
        btnHeight: 28,
        btnWidth: 80,
        onBtnClick: (): void => this.onActionClick()
      });
    } else {
      Text(this.getStatusText(this.getCouponStatus()))
        .fontSize($r("app.float.body_medium"))
        .fontColor(this.getCouponStatus() === CouponStatus.SELECTED ? $r("app.color.primary") :
          $r("app.color.text_tertiary"));
    }
  }

  /**
   * 获取可用状态操作文案
   * @returns {ResourceStr} 操作文案
   */
  private getAvailableActionText(): ResourceStr {
    if (this.mode === CouponCardMode.RECEIVE) {
      return $r("app.string.coupon_receive");
    }
    if (this.mode === CouponCardMode.SELECT) {
      return $r("app.string.goods_select");
    }
    return $r("app.string.coupon_use");
  }

  /**
   * 获取状态文案
   * @param {CouponStatus} status - 优惠券状态
   * @returns {ResourceStr} 状态文案
   */
  private getStatusText(status: CouponStatus): ResourceStr {
    if (status === CouponStatus.SELECTED) {
      return $r("app.string.selected");
    }
    if (status === CouponStatus.USED) {
      return $r("app.string.coupon_used");
    }
    if (status === CouponStatus.EXPIRED) {
      return $r("app.string.coupon_expired");
    }
    return $r("app.string.coupon_insufficient");
  }

  /**
   * 获取优惠券状态
   * @returns {CouponStatus} 优惠券状态
   */
  private getCouponStatus(): CouponStatus {
    if (this.coupon.useStatus === 1) {
      return CouponStatus.USED;
    }
    if (this.coupon.useStatus === 2 || this.isExpired(this.coupon.endTime)) {
      return CouponStatus.EXPIRED;
    }

    if (this.mode === CouponCardMode.SELECT && this.currentPrice !== null && this.coupon.condition) {
      const fullAmount: number = this.coupon.condition.fullAmount ?? 0;
      if (this.currentPrice < fullAmount) {
        return CouponStatus.INSUFFICIENT;
      }
      return this.isSelected ? CouponStatus.SELECTED : CouponStatus.AVAILABLE;
    }

    if (this.mode === CouponCardMode.SELECT && this.isSelected) {
      return CouponStatus.SELECTED;
    }

    return CouponStatus.AVAILABLE;
  }

  /**
   * 判断是否不可用状态
   * @param {CouponStatus} status - 优惠券状态
   * @returns {boolean} 是否不可用
   */
  private isUnavailable(status: CouponStatus): boolean {
    return status === CouponStatus.USED || status === CouponStatus.EXPIRED || status === CouponStatus.INSUFFICIENT;
  }

  /**
   * 判断字符串是否有值
   * @param {string | null | undefined} value - 原始文本
   * @returns {boolean} 是否有值
   */
  private hasText(value: string | null | undefined): boolean {
    if (!value) {
      return false;
    }
    return value.trim().length > 0;
  }

  /**
   * 判断优惠券是否已过期
   * @param {string | null | undefined} endTime - 结束时间
   * @returns {boolean} 是否过期
   */
  private isExpired(endTime: string | null | undefined): boolean {
    if (!this.hasText(endTime)) {
      return false;
    }
    try {
      const normalized: string = `${endTime}`.trim().replace(/-/g, "/");
      const expireTime: number = new Date(normalized).getTime();
      if (Number.isNaN(expireTime)) {
        return false;
      }
      return expireTime < Date.now();
    } catch (_err) {
      return false;
    }
  }
}
