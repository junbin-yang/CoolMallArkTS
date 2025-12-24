import { Auth, NetworkResponse } from 'model';

/**
 * 认证相关网络数据源接口
 * 定义认证模块所需的所有网络请求操作
 * @author Joker.X
 */
export interface AuthNetworkDataSource {
  /**
   * 密码登录
   * @param params 登录参数，包含用户名、密码等
   * @return 返回 Promise，包含认证结果
   */
  loginByPassword(params: Record<string, string>): Promise<NetworkResponse<Auth>>;
}
