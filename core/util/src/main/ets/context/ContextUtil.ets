import { UIContext } from "@ohos.arkui.UIContext";
import common from "@ohos.app.ability.common";

/**
 * @file Context 获取工具，统一从 UIContext 获取 hostContext
 * @author Joker.X
 */

/**
 * 具备 getUIContext 能力的组件接口
 */
interface WithUIContext {
  getUIContext?: () => UIContext | undefined;
}

/**
 * 获取组件关联的 hostContext（UIAbilityContext）
 * @param {WithUIContext | undefined} component 组件实例（需具备 getUIContext 方法）
 * @returns {common.Context | undefined} hostContext；获取失败返回 undefined
 */
export function getHostCtx(component?: WithUIContext): common.Context | undefined {
  const uiContext: UIContext | undefined = component?.getUIContext?.();
  return uiContext?.getHostContext();
}
