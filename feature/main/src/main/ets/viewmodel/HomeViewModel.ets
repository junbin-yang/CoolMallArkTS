import { BaseNetWorkListUiState, BaseNetWorkListViewModel } from "base";
import { GoodsRepository, PageRepository } from "data";
import { Category, Goods, GoodsSearchRequest, Home, NetworkPageData, NetworkResponse } from "model";
import { GoodsNavigator } from "navigation";
import { GoodsCategoryParam } from "navigation/src/main/ets/goods/GoodsParam";
import { RequestHelper } from "result";

/**
 * @file 首页 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class HomeViewModel extends BaseNetWorkListViewModel<Goods> {
  /**
   * 商品仓库
   */
  private goodsRepository: GoodsRepository = new GoodsRepository();
  /**
   * 页面数据仓库
   */
  private pageRepository: PageRepository = new PageRepository();
  /**
   * 首页页面数据
   */
  @Trace
  pageData: Home = new Home();

  /**
   * 重写请求列表数据方法来实现全部商品分页
   *
   * @return 商品分页数据流
   */
  protected requestListData(): Promise<NetworkResponse<NetworkPageData<Goods>>> {
    const request = new GoodsSearchRequest();
    request.page = this.currentPage;
    request.size = this.pageSize;
    return this.goodsRepository.getGoodsPage(request);
  }

  /**
   * 页面出现时初始化页面数据
   * @returns {void} 无返回值
   */
  aboutToAppear(): void {
    this.loadHomeData();
  }

  /**
   * 加载首页数据
   * @returns {void} 无返回值
   */
  loadHomeData(): void {
    RequestHelper.repository<Home>(this.pageRepository.getHomeData())
      .toast(false)
      .execute()
      .then((data: Home): void => {
        const homeData: Home = new Home(data);
        this.pageData = new Home(data);
        this.listData = homeData.goods ?? [];
        this.uiState = BaseNetWorkListUiState.SUCCESS;
      })
      .catch((): void => {
        this.uiState = BaseNetWorkListUiState.ERROR;
      })
      .finally((): void => {
        this.isLoading = false;
      });
  }

  /**
   * 触发下拉刷新
   * @returns {void} 无返回值
   */
  onRefresh(): void {
    if (this.isLoading) {
      return;
    }
    this.isLoading = true;
    this.currentPage = 1;
    this.loadHomeData();
  }

  /**
   * 重试请求
   * @returns {void} 无返回值
   */
  retryRequest(): void {
    this.uiState = BaseNetWorkListUiState.LOADING;
    this.currentPage = 1;
    this.loadHomeData();
  }

  /**
   * 跳转到商品分类页面
   * @param {number} categoryId - 分类 ID
   * @returns {void} 无返回值
   */
  toGoodsCategoryPage(categoryId: number): void {
    const allCategories: Category[] = this.pageData.categoryAll ?? [];
    const childCategoryIds: number[] = this.findChildCategoryIds(categoryId, allCategories);
    const typeIdParam: string = childCategoryIds.join(",");
    const params: GoodsCategoryParam = {
      typeId: typeIdParam,
      featured: false,
      recommend: false,
      keyword: undefined
    };
    GoodsNavigator.toCategory(params);
  }

  /**
   * 跳转到限时精选页面
   * @returns {void} 无返回值
   */
  toFlashSalePage(): void {
    const params: GoodsCategoryParam = {
      typeId: undefined,
      featured: true,
      recommend: false,
      keyword: undefined
    };
    GoodsNavigator.toCategory(params);
  }

  /**
   * 跳转到推荐商品页面
   * @returns {void} 无返回值
   */
  toRecommendPage(): void {
    const params: GoodsCategoryParam = {
      typeId: undefined,
      featured: false,
      recommend: true,
      keyword: undefined
    };
    GoodsNavigator.toCategory(params);
  }

  /**
   * 查找指定分类的子分类 ID
   * @param {number} parentId - 父分类 ID
   * @param {Category[]} allCategories - 全部分类列表
   * @returns {number[]} 子分类 ID 列表
   */
  private findChildCategoryIds(parentId: number, allCategories: Category[]): number[] {
    return allCategories
      .filter((item: Category): boolean => item.parentId === parentId)
      .map((item: Category): number => item.id);
  }
}
