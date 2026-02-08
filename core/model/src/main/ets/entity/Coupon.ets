import { Condition } from "./Condition";

/**
 * @file 优惠券信息
 * @author Joker.X
 */
export class Coupon {
  /**
   * ID
   */
  id: number = 0;
  /**
   * 标题
   */
  title: string = "";
  /**
   * 描述
   */
  description: string = "";
  /**
   * 类型 0-满减
   */
  type: number = 0;
  /**
   * 金额
   */
  amount: number = 0.0;
  /**
   * 数量
   */
  num: number = 0;
  /**
   * 已领取
   */
  receivedNum: number = 0;
  /**
   * 开始时间
   */
  startTime?: string | null = null;
  /**
   * 结束时间
   */
  endTime?: string | null = null;
  /**
   * 状态 0-禁用 1-启用
   */
  status: number = 0;
  /**
   * 条件
   */
  condition?: Condition | null = null;
  /**
   * 创建时间
   */
  createTime?: string | null = null;
  /**
   * 更新时间
   */
  updateTime?: string | null = null;
  /**
   * 使用状态 0-未使用 1-已使用 2-已过期（我的优惠券接口）
   */
  useStatus?: number | null = null;

  constructor(init?: Partial<Coupon> | ICouponRaw) {
    if (!init) {
      return;
    }
    const raw: ICouponRaw = init as ICouponRaw;
    this.id = (init as Partial<Coupon>).id ?? this.id;
    this.title = (init as Partial<Coupon>).title ?? this.title;
    this.description = (init as Partial<Coupon>).description ?? this.description;
    this.type = (init as Partial<Coupon>).type ?? this.type;
    this.amount = (init as Partial<Coupon>).amount ?? this.amount;
    this.num = (init as Partial<Coupon>).num ?? this.num;
    this.receivedNum = (init as Partial<Coupon>).receivedNum ?? this.receivedNum;
    this.startTime = (init as Partial<Coupon>).startTime ?? this.startTime;
    this.endTime = (init as Partial<Coupon>).endTime ?? this.endTime;
    this.status = (init as Partial<Coupon>).status ?? this.status;
    const fallbackCondition: string | Condition | Object | null | undefined = raw.condition$1;
    const rawCondition: string | Condition | Object | null | undefined = raw.condition ?? fallbackCondition;
    this.condition = this.parseCondition(rawCondition);
    this.createTime = (init as Partial<Coupon>).createTime ?? this.createTime;
    this.updateTime = (init as Partial<Coupon>).updateTime ?? this.updateTime;
    this.useStatus = (init as Partial<Coupon>).useStatus ?? this.useStatus;
  }

  /**
   * 解析优惠券条件字段
   * @param {string | Condition | Object | null | undefined} rawCondition - 原始条件数据
   * @returns {Condition | null} 解析后的条件
   */
  private parseCondition(rawCondition: string | Condition | Object | null | undefined): Condition | null {
    if (rawCondition === null || rawCondition === undefined) {
      return null;
    }
    if (rawCondition instanceof Condition) {
      return rawCondition;
    }
    if (typeof rawCondition === "string") {
      const trimmed: string = rawCondition.trim();
      if (trimmed.length === 0) {
        return null;
      }
      try {
        const parsed: Object = JSON.parse(trimmed) as Object;
        return new Condition(parsed as Condition);
      } catch (_error) {
        return null;
      }
    }
    if (rawCondition instanceof Object) {
      return new Condition(rawCondition as Condition);
    }
    return null;
  }
}


/**
 * 优惠券原始数据结构
 */
interface ICouponRaw {
  /**
   * 优惠券条件（接口可能返回字符串）
   */
  condition?: string | Condition | Object | null;
  /**
   * 条件对象备选字段
   */
  "condition$1"?: string | Condition | Object | null;
}