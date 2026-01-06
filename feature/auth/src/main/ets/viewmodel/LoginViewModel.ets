import { BaseViewModel } from "base";
import { AuthRoutes, CommonRoutes, navigateTo } from "navigation";

/**
 * @file 登录页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class LoginViewModel extends BaseViewModel {
  /**
   * 跳转到短信验证码登录页面
   * @returns {void} 无返回值
   */
  toSmsLoginPage(): void {
    navigateTo(AuthRoutes.SmsLogin);
  }

  /**
   * 跳转到账号密码登录页面
   * @returns {void} 无返回值
   */
  toAccountLoginPage(): void {
    navigateTo(AuthRoutes.AccountLogin);
  }

  /**
   * 微信登录点击
   * @returns {void} 无返回值
   */
  onWechatLoginClick(): void {
    // 第三方登录暂未接入，等待后续实现
  }

  /**
   * QQ 登录点击
   * @returns {void} 无返回值
   */
  onQQLoginClick(): void {
    // 第三方登录暂未接入，等待后续实现
  }

  /**
   * 支付宝登录点击
   * @returns {void} 无返回值
   */
  onAlipayLoginClick(): void {
    // 第三方登录暂未接入，等待后续实现
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
