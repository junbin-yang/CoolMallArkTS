import { BaseViewModel } from "base";
import { CommonRoutes, navigateBack, navigateTo } from "navigation";

/**
 * @file 短信登录页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class SmsLoginViewModel extends BaseViewModel {
  /**
   * 更新手机号
   * @param {string} value - 手机号
   * @returns {void} 无返回值
   */
  updatePhone(value: string): void {
  }

  /**
   * 更新验证码
   * @param {string} value - 验证码
   * @returns {void} 无返回值
   */
  updateVerificationCode(value: string): void {
  }

  /**
   * 发送验证码
   * @returns {void} 无返回值
   */
  onSendVerificationCode(): void {
  }

  /**
   * 登录按钮点击
   * @returns {void} 无返回值
   */
  login(): void {
  }

  /**
   * 返回上一页
   * @returns {void} 无返回值
   */
  navigateBack(): void {
    navigateBack();
  }

  /**
   * 打开用户协议页面
   * @returns {void} 无返回值
   */
  onUserAgreementClick(): void {
    navigateTo(CommonRoutes.UserAgreement);
  }

  /**
   * 打开隐私政策页面
   * @returns {void} 无返回值
   */
  onPrivacyPolicyClick(): void {
    navigateTo(CommonRoutes.PrivacyPolicy);
  }
}
