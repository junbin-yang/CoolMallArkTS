import { BaseNetWorkViewModel } from "base";
import { GoodsRepository } from "data";
import { Category, CategoryTree, NetworkResponse } from "model";
import { GoodsNavigator } from "navigation";
import { GoodsCategoryParam } from "navigation/src/main/ets/goods/GoodsParam";

/**
 * @file 分类页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class CategoryViewModel extends BaseNetWorkViewModel<Category[]> {
  /**
   * 商品仓库
   */
  private goodsRepository: GoodsRepository = new GoodsRepository();
  /**
   * 分类树数据
   */
  @Trace
  categoryTrees: CategoryTree[] = [];
  /**
   * 左侧分类标题列表
   */
  @Trace
  categoryTitles: string[] = [];
  /**
   * 当前选中的分类索引
   */
  @Trace
  selectedCategoryIndex: number = -1;
  /**
   * 是否正在执行侧边栏联动滚动
   */
  @Trace
  isSideBarScrolling: boolean = false;
  /**
   * 侧边栏上一次选中索引
   */
  @Trace
  lastSideBarIndex: number = 0;
  /**
   * 侧边栏联动滚动解锁计时器
   */
  private sideBarUnlockTimer: number = -1;

  /**
   * 重写请求方法来实现网络请求
   *
   * @return 商品分类
   */
  protected requestRepository(): Promise<NetworkResponse<Category[]>> {
    return this.goodsRepository.getGoodsTypeList();
  }

  /**
   * 请求成功后处理分类树数据
   * @param {Category[]} data - 分类列表
   * @returns {void} 无返回值
   */
  protected onRequestSuccess(data: Category[]): void {
    this.categoryTrees = this.convertToTree(data);
    this.categoryTitles = this.categoryTrees.map((item: CategoryTree): string => item.name);
    this.isSideBarScrolling = false;
    this.lastSideBarIndex = 0;
    this.clearSideBarUnlockTimer();
    if (this.categoryTrees.length > 0) {
      if (this.selectedCategoryIndex < 0 || this.selectedCategoryIndex >= this.categoryTrees.length) {
        this.selectedCategoryIndex = 0;
      }
    } else {
      this.selectedCategoryIndex = -1;
    }
    super.onRequestSuccess(data);
  }

  /**
   * 处理侧边栏选中事件
   * @param {number} index - 目标索引
   * @returns {number} 实际滚动目标索引
   */
  onSideBarSelected(index: number): number {
    const targetIndex: number = this.clampIndex(index);
    this.isSideBarScrolling = true;
    this.selectedCategoryIndex = targetIndex;
    this.startSideBarUnlockTimer(targetIndex);
    return targetIndex;
  }

  /**
   * 结束侧边栏联动滚动
   * @returns {void} 无返回值
   */
  finishSideBarScroll(): void {
    this.isSideBarScrolling = false;
  }

  /**
   * 处理右侧列表滚动事件
   * @param {number} startIndex - 当前可见起始索引
   * @returns {void} 无返回值
   */
  onRightListScroll(startIndex: number): void {
    if (startIndex < 0) {
      return;
    }
    if (this.isSideBarScrolling) {
      return;
    }
    if (startIndex !== this.selectedCategoryIndex) {
      this.selectedCategoryIndex = startIndex;
    }
  }

  /**
   * 获取侧边栏当前激活索引
   * @returns {number} 当前激活索引
   */
  getActiveIndex(): number {
    return this.selectedCategoryIndex < 0 ? 0 : this.selectedCategoryIndex;
  }

  /**
   * 校验侧边栏索引合法性
   * @param {number} index - 原始索引
   * @returns {number} 合法索引，不合法返回 -1
   */
  private clampIndex(index: number): number {
    const total: number = this.categoryTrees.length;
    if (total <= 0) {
      return 0;
    }
    if (index < 0) {
      return 0;
    }
    if (index >= total) {
      return total - 1;
    }
    return index;
  }

  /**
   * 计算联动解锁时长
   * @param {number} targetIndex - 目标索引
   * @returns {number} 解锁时长（毫秒）
   */
  private calculateUnlockDuration(targetIndex: number): number {
    const distance: number = Math.abs(targetIndex - this.lastSideBarIndex);
    this.lastSideBarIndex = targetIndex;
    return Math.min(1200, Math.max(240, distance * 120));
  }

  /**
   * 跳转到商品分类页面
   * @param {number} categoryId - 分类 ID
   * @returns {void} 无返回值
   */
  toGoodsCategoryPage(categoryId: number): void {
    const params: GoodsCategoryParam = {
      typeId: `${categoryId}`,
      featured: false,
      recommend: false,
      keyword: undefined
    };
    GoodsNavigator.toCategory(params);
  }

  /**
   * 启动侧边栏联动解锁计时器
   * @param {number} targetIndex - 目标索引
   * @returns {void} 无返回值
   */
  private startSideBarUnlockTimer(targetIndex: number): void {
    this.clearSideBarUnlockTimer();
    const duration: number = this.calculateUnlockDuration(targetIndex);
    this.sideBarUnlockTimer = setTimeout((): void => {
      this.finishSideBarScroll();
      this.sideBarUnlockTimer = -1;
    }, duration);
  }

  /**
   * 清理侧边栏联动解锁计时器
   * @returns {void} 无返回值
   */
  private clearSideBarUnlockTimer(): void {
    if (this.sideBarUnlockTimer >= 0) {
      clearTimeout(this.sideBarUnlockTimer);
      this.sideBarUnlockTimer = -1;
    }
  }

  /**
   * 页面隐藏时清理计时器
   * @returns {void} 无返回值
   */
  aboutToDisappear(): void {
    this.clearSideBarUnlockTimer();
  }

  /**
   * 页面销毁时清理计时器
   * @returns {void} 无返回值
   */
  aboutToBeDeleted(): void {
    this.clearSideBarUnlockTimer();
  }

  /**
   * 将分类列表转换为树形结构
   * @param {Category[]} categories - 原始分类列表
   * @returns {CategoryTree[]} 树形结构的分类列表
   * @example
  * const tree = this.convertToTree(list);
   */
  private convertToTree(categories: Category[]): CategoryTree[] {
    return CategoryTree.buildTree(categories);
  }
}
