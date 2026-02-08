/**
 * @file 优惠券卡片枚举定义
 * @author Joker.X
 */

/**
 * 优惠券卡片模式
 */
export enum CouponCardMode {
  /**
   * 领取模式
   */
  RECEIVE = "receive",
  /**
   * 选择模式
   */
  SELECT = "select",
  /**
   * 查看模式
   */
  VIEW = "view"
}

/**
 * 优惠券状态
 */
export enum CouponStatus {
  /**
   * 可用
   */
  AVAILABLE = "available",
  /**
   * 已选择
   */
  SELECTED = "selected",
  /**
   * 已使用
   */
  USED = "used",
  /**
   * 已过期
   */
  EXPIRED = "expired",
  /**
   * 不满足条件
   */
  INSUFFICIENT = "insufficient"
}
