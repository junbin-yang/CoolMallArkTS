import { NetworkClient } from '../../NetworkClient';
import { Auth, NetworkResponse } from 'model';
import { AxiosResponse } from '@ohos/axios';
import { AuthNetworkDataSource } from './AuthNetworkDataSource';

/**
 * 认证相关网络数据源实现类
 * @author Joker.X
 */
export class AuthNetworkDataSourceImpl implements AuthNetworkDataSource {
  /**
   * 密码登录实现
   * @param params 登录参数
   */
  async loginByPassword(params: Record<string, string>): Promise<NetworkResponse<Auth>> {
    const response: AxiosResponse<NetworkResponse<Auth>> = await NetworkClient.http.post('user/login/password', params);
    return response.data;
  }
}
