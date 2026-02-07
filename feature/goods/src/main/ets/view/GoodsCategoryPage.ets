import { KeyboardAvoidMode, UIContext } from "@ohos.arkui.UIContext";
import { ColumnStart, P100 } from "designsystem";
import { Goods } from "model";
import { navigateBack } from "navigation";
import { bp } from "state";
import {
  AppNavDestination,
  BaseNetWorkListView,
  GoodsGridItem,
  GoodsListItem,
  RefreshLayout,
  SearchTopAppBar
} from "ui";
import { GoodsCategoryFilterBar } from "../component/GoodsCategoryFilterBar";
import GoodsCategoryViewModel from "../viewmodel/GoodsCategoryViewModel";
import { GoodsNavigator } from "navigation";

/**
 * @file 商品分类页面视图
 * @author Joker.X
 */
@ComponentV2
export struct GoodsCategoryPage {
  /**
   * 商品分类页面 ViewModel
   */
  @Local
  private vm: GoodsCategoryViewModel = new GoodsCategoryViewModel();
  /**
   * 搜索输入值
   */
  @Local
  private searchValue: string = "";
  /**
   * 列表滚动控制器
   */
  private readonly listScroller: Scroller = new Scroller();

  /**
   * 页面显示前设置键盘避让模式
   * @returns {void} 无返回值
   */
  aboutToAppear(): void {
    const uiContext: UIContext = this.getUIContext();
    this.vm.snapshotKeyboardAvoidMode(uiContext.getKeyboardAvoidMode());
    uiContext.setKeyboardAvoidMode(KeyboardAvoidMode.NONE);
    this.searchValue = this.vm.getCurrentSearchKeyword();
  }

  /**
   * 页面离开时恢复键盘避让模式
   * @returns {void} 无返回值
   */
  aboutToDisappear(): void {
    const previousMode: KeyboardAvoidMode | null = this.vm.consumeKeyboardAvoidModeSnapshot();
    if (previousMode === null) {
      return;
    }
    const uiContext: UIContext = this.getUIContext();
    uiContext.setKeyboardAvoidMode(previousMode);
  }

  /**
   * 构建商品分类页面
   * @returns {void} 无返回值
   */
  build(): void {
    AppNavDestination({
      viewModel: this.vm,
      hideTitleBar: true
    }) {
      ColumnStart({
        fillMaxSize: true,
        bgColor: $r("app.color.bg_grey")
      }) {
        SearchTopAppBar({
          value: this.searchValue,
          onValueChange: (value: string): void => {
            this.searchValue = value;
          },
          onSearch: (value: string): void => {
            this.searchValue = value.trim();
            this.vm.onSearch(this.searchValue);
          },
          onBackClick: (): void => navigateBack()
        });

        GoodsCategoryFilterBar({
          currentSortType: this.vm.currentSortType,
          currentSortState: this.vm.currentSortState,
          categoryUiState: this.vm.categoryUiState,
          categoryTreeList: this.vm.categoryTreeList,
          selectedCategoryIds: this.vm.selectedCategoryIds,
          minPrice: this.vm.minPrice,
          maxPrice: this.vm.maxPrice,
          isGridLayout: this.vm.isGridLayout,
          onFiltersClick: (): void => this.vm.showFilters(),
          onSortClick: (sortType): void => this.vm.onSortClick(sortType),
          onApplyFilters: (categoryIds: number[], minPrice: string, maxPrice: string): void =>
          this.vm.applyFilters(categoryIds, minPrice, maxPrice),
          onResetFilters: (): void => this.vm.resetFilters(),
          onToggleLayoutMode: (): void => this.vm.toggleLayoutMode()
        });

        BaseNetWorkListView({
          uiState: this.vm.uiState,
          onRetry: (): void => this.vm.retryRequest(),
          content: (): void => this.GoodsCategoryContent()
        }).layoutWeight(1);
      }
    }
  }

  /**
   * 商品分类页面内容
   * @returns {void} 无返回值
   */
  @Builder
  private GoodsCategoryContent(): void {
    RefreshLayout({
      loading: this.vm.isLoading,
      isEnableSlideUp: this.vm.isEnableSlideUp,
      scroller: this.listScroller,
      onRefresh: (direction: "pull" | "slideUp"): void => this.vm.onRefreshDirection(direction)
    }) {
      if (this.vm.isGridLayout) {
        this.GoodsGridContent();
      } else {
        this.GoodsListContent();
      }
    }
  }

  /**
   * 商品列表布局
   * @returns {void} 无返回值
   */
  @Builder
  private GoodsListContent(): void {
    Grid(this.listScroller) {
      ForEach(this.vm.listData, (item: Goods): void => {
        GridItem() {
          GoodsListItem({
            goods: item,
            onItemClick: (id: number): void => GoodsNavigator.toDetail(id)
          });
        }
      }, (item: Goods): string => `${item.id}`);
    }
    .columnsTemplate(bp({ sm: "1fr", md: "1fr 1fr", lg: "1fr 1fr" }))
    .columnsGap($r("app.float.space_padding_small"))
    .rowsGap($r("app.float.space_padding_small"))
    .width(P100)
    .edgeEffect(EdgeEffect.None)
    .padding($r("app.float.space_padding_medium"));
  }

  /**
   * 商品网格布局
   * @returns {void} 无返回值
   */
  @Builder
  private GoodsGridContent(): void {
    Grid(this.listScroller) {
      ForEach(this.vm.listData, (item: Goods): void => {
        GridItem() {
          GoodsGridItem({
            goods: item,
            onItemClick: (id: number): void => GoodsNavigator.toDetail(id)
          });
        }
      }, (item: Goods): string => `${item.id}`);
    }
    .columnsTemplate(bp({ sm: "1fr 1fr", md: "1fr 1fr 1fr", lg: "1fr 1fr 1fr 1fr" }))
    .columnsGap($r("app.float.space_padding_small"))
    .rowsGap($r("app.float.space_padding_small"))
    .width(P100)
    .edgeEffect(EdgeEffect.None)
    .padding($r("app.float.space_padding_medium"));
  }
}
