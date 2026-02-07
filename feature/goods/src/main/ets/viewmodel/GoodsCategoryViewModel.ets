import { KeyboardAvoidMode } from "@ohos.arkui.UIContext";
import { BaseNetWorkListViewModel, BaseNetWorkUiState } from "base";
import { GoodsRepository } from "data";
import { Category, CategoryTree, Goods, GoodsSearchRequest, NetworkPageData, NetworkResponse } from "model";
import { getRouteParams } from "navigation";
import { GoodsCategoryParam } from "navigation/src/main/ets/goods/GoodsParam";
import { GoodsRoutes } from "navigation/src/main/ets/goods/GoodsRoutes";
import { RequestHelper } from "result";
import { OrderSortPair } from "../model/OrderSortPair";
import { SortState } from "../model/SortState";
import { SortType } from "../model/SortType";

/**
 * @file 商品分类页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class GoodsCategoryViewModel extends BaseNetWorkListViewModel<Goods> {
  /**
   * 商品仓库
   */
  private readonly goodsRepository: GoodsRepository = new GoodsRepository();
  /**
   * 路由参数
   */
  private readonly routeParam: GoodsCategoryParam | undefined =
    getRouteParams<GoodsCategoryParam>(GoodsRoutes.Category);
  /**
   * 搜索关键词
   */
  private searchKeyword: string = this.routeParam?.keyword ?? "";
  /**
   * 是否为限时精选
   */
  private isFeatured: boolean = this.routeParam?.featured ?? false;
  /**
   * 是否为推荐商品
   */
  private isRecommend: boolean = this.routeParam?.recommend ?? false;
  /**
   * 分类数据是否已加载
   */
  private categoryDataLoaded: boolean = false;
  /**
   * 页面进入前的键盘避让模式
   */
  private previousKeyboardAvoidMode: KeyboardAvoidMode = KeyboardAvoidMode.OFFSET;
  /**
   * 是否已记录键盘避让模式
   */
  private hasKeyboardAvoidModeSnapshot: boolean = false;
  /**
   * 分类筛选网络状态
   */
  @Trace
  categoryUiState: BaseNetWorkUiState = BaseNetWorkUiState.LOADING;
  /**
   * 选中的分类 ID 列表
   */
  @Trace
  selectedCategoryIds: number[] = this.parseCategoryIds(this.routeParam?.typeId ?? "");
  /**
   * 最低价格
   */
  @Trace
  minPrice: string = this.routeParam?.minPrice ?? "";
  /**
   * 最高价格
   */
  @Trace
  maxPrice: string = "";
  /**
   * 当前排序类型
   */
  @Trace
  currentSortType: SortType = SortType.COMPREHENSIVE;
  /**
   * 当前排序状态
   */
  @Trace
  currentSortState: SortState = SortState.NONE;
  /**
   * 分类树数据
   */
  @Trace
  categoryTreeList: CategoryTree[] = [];
  /**
   * 是否为网格布局
   */
  @Trace
  isGridLayout: boolean = true;
  /**
   * 排序参数映射
   */
  private static readonly ORDER_SORT_MAP: Map<string, OrderSortPair> = new Map<string, OrderSortPair>([
    [`${SortType.SALES}_${SortState.ASC}`, { order: "sold", sort: "asc" }],
    [`${SortType.SALES}_${SortState.DESC}`, { order: "sold", sort: "desc" }],
    [`${SortType.PRICE}_${SortState.ASC}`, { order: "price", sort: "asc" }],
    [`${SortType.PRICE}_${SortState.DESC}`, { order: "price", sort: "desc" }]
  ]);
  /**
   * 排序状态流映射
   */
  private static readonly SORT_STATE_FLOW_MAP: Map<SortType, SortState[]> = new Map<SortType, SortState[]>([
    [SortType.COMPREHENSIVE, [SortState.NONE]],
    [SortType.SALES, [SortState.NONE, SortState.ASC, SortState.DESC]],
    [SortType.PRICE, [SortState.NONE, SortState.ASC, SortState.DESC]]
  ]);

  /**
   * 解析分类 ID 列表
   * @param {string} typeIdParam - 分类参数
   * @returns {number[]} 分类 ID 列表
   */
  private parseCategoryIds(typeIdParam: string): number[] {
    if (typeIdParam.trim().length === 0) {
      return [];
    }
    return typeIdParam
      .split(",")
      .map((id: string): number => Number(id.trim()))
      .filter((id: number): boolean => !Number.isNaN(id) && id > 0);
  }

  /**
   * 获取当前搜索关键词
   * @returns {string} 搜索关键词
   */
  getCurrentSearchKeyword(): string {
    return this.searchKeyword;
  }

  /**
   * 记录键盘避让模式
   * @param {KeyboardAvoidMode} mode - 当前模式
   * @returns {void} 无返回值
   */
  snapshotKeyboardAvoidMode(mode: KeyboardAvoidMode): void {
    this.previousKeyboardAvoidMode = mode;
    this.hasKeyboardAvoidModeSnapshot = true;
  }

  /**
   * 获取并清除键盘避让模式快照
   * @returns {KeyboardAvoidMode | null} 之前模式
   */
  consumeKeyboardAvoidModeSnapshot(): KeyboardAvoidMode | null {
    if (!this.hasKeyboardAvoidModeSnapshot) {
      return null;
    }
    this.hasKeyboardAvoidModeSnapshot = false;
    return this.previousKeyboardAvoidMode;
  }

  /**
   * 请求商品分页数据
   * @returns {Promise<NetworkResponse<NetworkPageData<Goods>>>} 网络请求 Promise
   */
  protected requestListData(): Promise<NetworkResponse<NetworkPageData<Goods>>> {
    const orderSortPair: OrderSortPair = this.getOrderSortPair();
    const request: GoodsSearchRequest = new GoodsSearchRequest();
    request.page = this.currentPage;
    request.size = this.pageSize;
    request.featured = this.isFeatured ? true : undefined;
    request.recommend = this.isRecommend ? true : undefined;
    request.typeId = this.selectedCategoryIds.length > 0 ? [...this.selectedCategoryIds] : undefined;
    request.minPrice = this.getOptionalString(this.minPrice);
    request.maxPrice = this.getOptionalString(this.maxPrice);
    request.order = orderSortPair.order;
    request.sort = orderSortPair.sort;
    request.keyWord = this.getOptionalString(this.searchKeyword);

    return this.goodsRepository.getGoodsPage(request);
  }

  /**
   * 显示筛选面板
   * @returns {void} 无返回值
   */
  showFilters(): void {
    if (this.categoryDataLoaded) {
      return;
    }
    this.loadGoodsCategory();
  }

  /**
   * 应用筛选条件并刷新数据
   * @param {number[]} categoryIds - 分类 ID 列表
   * @param {string} minPrice - 最低价格
   * @param {string} maxPrice - 最高价格
   * @returns {void} 无返回值
   */
  applyFilters(categoryIds: number[], minPrice: string, maxPrice: string): void {
    this.selectedCategoryIds = [...categoryIds];
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    this.onRefresh();
  }

  /**
   * 重置筛选条件
   * @returns {void} 无返回值
   */
  resetFilters(): void {
    this.selectedCategoryIds = [];
    this.minPrice = "";
    this.maxPrice = "";
    this.onRefresh();
  }

  /**
   * 处理排序点击事件
   * @param {SortType} sortType - 点击的排序类型
   * @returns {void} 无返回值
   */
  onSortClick(sortType: SortType): void {
    const isSameType: boolean = this.currentSortType === sortType;
    const stateFlow: SortState[] = GoodsCategoryViewModel.SORT_STATE_FLOW_MAP.get(sortType) ?? [SortState.NONE];
    const currentState: SortState = isSameType ? this.currentSortState : SortState.NONE;
    const nextState: SortState = this.getNextSortState(stateFlow, currentState);

    this.currentSortState = nextState;
    this.currentSortType = nextState === SortState.NONE ? SortType.COMPREHENSIVE : sortType;
    this.onRefresh();
  }

  /**
   * 搜索
   * @param {string} keyword - 搜索关键词
   * @returns {void} 无返回值
   */
  onSearch(keyword: string): void {
    this.searchKeyword = keyword;
    this.onRefresh();
  }

  /**
   * 切换布局模式
   * @returns {void} 无返回值
   */
  toggleLayoutMode(): void {
    this.isGridLayout = !this.isGridLayout;
  }

  /**
   * 加载商品分类
   * @returns {void} 无返回值
   */
  private loadGoodsCategory(): void {
    RequestHelper.repository<Category[]>(this.goodsRepository.getGoodsTypeList())
      .toast(true)
      .start((): void => {
        this.categoryUiState = BaseNetWorkUiState.LOADING;
      })
      .execute()
      .then((data: Category[]): void => {
        this.categoryTreeList = this.convertToTree(data ?? []);
        this.categoryUiState = BaseNetWorkUiState.SUCCESS;
        this.categoryDataLoaded = true;
      })
      .catch((): void => {
        this.categoryTreeList = [];
        this.categoryUiState = BaseNetWorkUiState.ERROR;
      });
  }

  /**
   * 获取排序参数
   * @returns {OrderSortPair} 排序参数
   */
  private getOrderSortPair(): OrderSortPair {
    const key: string = this.buildSortKey(this.currentSortType, this.currentSortState);
    return GoodsCategoryViewModel.ORDER_SORT_MAP.get(key) ?? {};
  }

  /**
   * 获取排序 Key
   * @param {SortType} sortType - 排序类型
   * @param {SortState} sortState - 排序状态
   * @returns {string} 排序 Key
   */
  private buildSortKey(sortType: SortType, sortState: SortState): string {
    return `${sortType}_${sortState}`;
  }

  /**
   * 获取排序状态的下一个状态
   * @param {SortState[]} stateFlow - 状态流
   * @param {SortState} currentState - 当前状态
   * @returns {SortState} 下一个状态
   */
  private getNextSortState(stateFlow: SortState[], currentState: SortState): SortState {
    const index: number = stateFlow.indexOf(currentState);
    if (index < 0) {
      return stateFlow[0] ?? SortState.NONE;
    }
    return stateFlow[(index + 1) % stateFlow.length];
  }

  /**
   * 获取非空字符串
   * @param {string} value - 原始值
   * @returns {string | undefined} 非空字符串
   */
  private getOptionalString(value: string): string | undefined {
    const normalized: string = value.trim();
    if (normalized.length === 0) {
      return undefined;
    }
    return normalized;
  }

  /**
   * 将分类列表转换为分类树
   * @param {Category[]} categories - 原始分类列表
   * @returns {CategoryTree[]} 分类树
   */
  private convertToTree(categories: Category[]): CategoryTree[] {
    return CategoryTree.buildTree(categories);
  }
}
