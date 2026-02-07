import {
  IBestButton,
  IBestDropdownItem,
  IBestDropdownMenu,
  IBestDropdownMenuController,
  IBestDropdownMenuOption
} from "ibestui";
import { BaseNetWorkUiState } from "base";
import {
  ColumnStart,
  P100,
  RowStartCenter,
  SpaceHorizontalXSmall,
  SpaceVerticalSmall,
  SpaceVerticalXSmall,
  VerticalScroll
} from "designsystem";
import { CategoryTree } from "model";
import { BaseNetWorkView, Card, CommonIcon, NetWorkImage } from "ui";
import { SortState } from "../model/SortState";
import { SortType } from "../model/SortType";

/**
 * @file 商品分类筛选与排序栏组件
 * @author Joker.X
 */
/**
 * 排序解析结果
 */
interface SortTarget {
  /**
   * 排序类型
   */
  type: SortType;

  /**
   * 排序状态
   */
  state: SortState;
}

@ComponentV2
export struct GoodsCategoryFilterBar {
  /**
   * 筛选面板最大高度
   */
  private static readonly FILTER_MENU_MAX_HEIGHT: number = 560;
  /**
   * 当前排序类型
   */
  @Param
  currentSortType: SortType = SortType.COMPREHENSIVE;
  /**
   * 当前排序状态
   */
  @Param
  currentSortState: SortState = SortState.NONE;
  /**
   * 分类网络状态
   */
  @Param
  categoryUiState: BaseNetWorkUiState = BaseNetWorkUiState.LOADING;
  /**
   * 分类树数据
   */
  @Param
  categoryTreeList: CategoryTree[] = [];
  /**
   * 选中的分类 ID 列表
   */
  @Param
  selectedCategoryIds: number[] = [];
  /**
   * 最低价格
   */
  @Param
  minPrice: string = "";
  /**
   * 最高价格
   */
  @Param
  maxPrice: string = "";
  /**
   * 是否网格布局
   */
  @Param
  isGridLayout: boolean = true;
  /**
   * 打开筛选下拉回调
   */
  @Param
  onFiltersClick: () => void = (): void => {
  };
  /**
   * 排序点击回调
   */
  @Param
  onSortClick: (sortType: SortType) => void = (_: SortType): void => {
  };
  /**
   * 重置筛选回调
   */
  @Param
  onResetFilters: () => void = (): void => {
  };
  /**
   * 应用筛选回调
   */
  @Param
  onApplyFilters: (categoryIds: number[], minPrice: string, maxPrice: string) => void =
    (_: number[], __: string, ___: string): void => {
    };
  /**
   * 切换布局回调
   */
  @Param
  onToggleLayoutMode: () => void = (): void => {
  };
  /**
   * 下拉菜单分组 ID
   */
  private readonly dropdownGroupId: string = "goods_category_dropdown";
  /**
   * 下拉菜单控制器
   */
  private readonly dropdownMenuController: IBestDropdownMenuController = new IBestDropdownMenuController();
  /**
   * 筛选内容滚动控制器
   */
  private readonly filterScroller: Scroller = new Scroller();
  /**
   * 草稿选中的分类 ID 列表
   */
  @Local
  private draftSelectedCategoryIds: number[] = [];
  /**
   * 草稿最低价格
   */
  @Local
  private draftMinPrice: string = "";
  /**
   * 草稿最高价格
   */
  @Local
  private draftMaxPrice: string = "";

  /**
   * 构建筛选与排序栏
   * @returns {void} 无返回值
   */
  build(): void {
    RowStartCenter({ widthValue: P100 }) {
      Row() {
        IBestDropdownMenu({
          groupId: this.dropdownGroupId,
          controller: this.dropdownMenuController,
          menuHeight: 32,
          bgColor: $r("app.color.bg_grey")
        }) {
          IBestDropdownItem({
            groupId: this.dropdownGroupId,
            title: $r("app.string.filter"),
            maxHeight: GoodsCategoryFilterBar.FILTER_MENU_MAX_HEIGHT,
            onOpen: (): void => this.handleFilterOpen(),

          }) {
            this.FilterMenuContent();
          }

          IBestDropdownItem({
            groupId: this.dropdownGroupId,
            value: this.getCurrentSortValue(),
            options: this.getSortMenuOptions(),
            onChange: (value: string | number): void => this.onSortSelectionChange(`${value}`)
          });
        }
      }
      .layoutWeight(1);

      Row() {
        CommonIcon({
          icon: this.isGridLayout ? $r("app.media.ic_menu_list") : $r("app.media.ic_menu"),
          iconSize: 20,
          tintColor: $r("app.color.text_primary"),
          onTap: (): void => this.onToggleLayoutMode()
        });
      }
      .margin({ right: $r("app.float.space_horizontal_large") });
    }
  }

  /**
   * 下拉筛选内容
   * @returns {void} 无返回值
   */
  @Builder
  private FilterMenuContent(): void {
    BaseNetWorkView({
      uiState: this.categoryUiState,
      onRetry: (): void => this.onFiltersClick(),
      content: (): void => this.FilterSuccessLayout()
    });
  }

  /**
   * 筛选成功态布局
   * @returns {void} 无返回值
   */
  @Builder
  private FilterSuccessLayout(): void {
    ColumnStart({
      widthValue: P100,
      heightValue: GoodsCategoryFilterBar.FILTER_MENU_MAX_HEIGHT,
      bgColor: $r("app.color.bg_grey")
    }) {
      VerticalScroll({
        scroller: this.filterScroller,
        scrollBarState: BarState.Auto,
        fillMaxWidth: true,
        fillMaxSize: false,
        content: (): void => this.FilterSuccessBody()
      })
        .layoutWeight(1);

      this.FilterActionSection();
    }
  }

  /**
   * 筛选成功态主体内容
   * @returns {void} 无返回值
   */
  @Builder
  private FilterSuccessBody(): void {
    ColumnStart({
      widthValue: P100,
      bgColor: $r("app.color.bg_grey"),
      paddingValue: {
        left: $r("app.float.space_padding_medium"),
        right: $r("app.float.space_padding_medium"),
        top: $r("app.float.space_padding_small"),
        bottom: $r("app.float.space_padding_medium")
      }
    }) {
      this.FilterPriceCard();
      SpaceVerticalSmall();

      ForEach(this.categoryTreeList, (categoryGroup: CategoryTree): void => {
        this.FilterCategoryCard(categoryGroup);
        SpaceVerticalSmall();
      }, (categoryGroup: CategoryTree): string => `${categoryGroup.id}`);
    }
  }

  /**
   * 价格筛选卡片
   * @returns {void} 无返回值
   */
  @Builder
  private FilterPriceCard(): void {
    Card({
      paddingValue: $r("app.float.space_padding_medium")
    }) {
      Text($r("app.string.price_range"))
        .fontSize($r("app.float.body_large"))
        .fontColor($r("app.color.text_primary"))
        .textAlign(TextAlign.Start)
        .width(P100);

      SpaceVerticalSmall();

      Row() {
        this.PriceInput(
          this.draftMinPrice,
          $r("app.string.min_price"),
          (value: string): void => {
            this.draftMinPrice = value;
          }
        );

        this.PriceInputDivider();

        this.PriceInput(
          this.draftMaxPrice,
          $r("app.string.max_price"),
          (value: string): void => {
            this.draftMaxPrice = value;
          }
        );
      }
      .width(P100)
      .alignItems(VerticalAlign.Center);
    }
  }

  /**
   * 价格输入分隔线
   * @returns {void} 无返回值
   */
  @Builder
  private PriceInputDivider(): void {
    Row() {
      Blank()
        .width(16)
        .height(1)
        .backgroundColor($r("app.color.border"));
    }
    .padding({
      left: $r("app.float.space_horizontal_small"),
      right: $r("app.float.space_horizontal_small")
    })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }

  /**
   * 价格输入框
   * @param {string} value - 当前输入值
   * @param {ResourceStr} placeholder - 占位提示
   * @param {(value: string) => void} onChange - 输入变化回调
   * @returns {void} 无返回值
   */
  @Builder
  private PriceInput(value: string, placeholder: ResourceStr, onChange: (value: string) => void): void {
    TextInput({
      text: value,
      placeholder: placeholder
    })
      .layoutWeight(1)
      .height(36)
      .borderRadius(20)
      .backgroundColor($r("app.color.bg_white"))
      .border({
        width: 1,
        color: $r("app.color.border")
      })
      .fontSize($r("app.float.body_large"))
      .fontColor($r("app.color.text_primary"))
      .placeholderColor($r("app.color.text_quaternary"))
      .padding({
        left: $r("app.float.space_horizontal_large"),
        right: $r("app.float.space_horizontal_large")
      })
      .textAlign(TextAlign.Start)
      .expandSafeArea([SafeAreaType.KEYBOARD])
      .onChange((text: string): void => onChange(text));
  }

  /**
   * 分类筛选卡片
   * @param {CategoryTree} categoryGroup - 分类分组
   * @returns {void} 无返回值
   */
  @Builder
  private FilterCategoryCard(categoryGroup: CategoryTree): void {
    Card({
      paddingValue: $r("app.float.space_padding_medium")
    }) {
      Text(categoryGroup.name)
        .fontSize($r("app.float.body_large"))
        .fontColor($r("app.color.text_primary"))
        .textAlign(TextAlign.Start)
        .width(P100);

      SpaceVerticalXSmall();

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.getCategoryOptions(categoryGroup), (category: CategoryTree): void => {
          this.FilterCategoryChip(category);
        }, (category: CategoryTree): string => `${categoryGroup.id}-${category.id}`);
      }
      .width(P100);
    }
  }

  /**
   * 分类选项标签
   * @param {CategoryTree} category - 分类信息
   * @returns {void} 无返回值
   */
  @Builder
  private FilterCategoryChip(category: CategoryTree): void {
    Row() {
      if (this.hasCategoryIcon(category)) {
        NetWorkImage({
          model: category.pic ?? "",
          sizeValue: 18
        });

        SpaceHorizontalXSmall();
      }

      Text(category.name)
        .fontSize($r("app.float.body_medium"))
        .fontColor(this.isDraftCategorySelected(category.id) ? $r("app.color.primary") :
          $r("app.color.text_secondary"));
    }
    .padding({
      left: $r("app.float.space_horizontal_medium"),
      right: $r("app.float.space_horizontal_medium"),
      top: $r("app.float.space_vertical_small"),
      bottom: $r("app.float.space_vertical_small")
    })
    .backgroundColor(this.isDraftCategorySelected(category.id) ? $r("app.color.bg_content") : $r("app.color.bg_white"))
    .border({
      width: 1,
      color: this.isDraftCategorySelected(category.id) ? $r("app.color.primary") : $r("app.color.border")
    })
    .borderRadius(999)
    .margin({
      right: $r("app.float.space_horizontal_small"),
      bottom: $r("app.float.space_vertical_small")
    })
    .onClick((): void => this.toggleDraftCategory(category.id));
  }

  /**
   * 筛选操作区域（固定在底部）
   * @returns {void} 无返回值
   */
  @Builder
  private FilterActionSection(): void {
    Row({ space: 12 }) {
      IBestButton({
        text: $r("app.string.reset"),
        type: "primary",
        plain: true,
        round: true,
        btnWidth: P100,
        btnHeight: 32,
        onBtnClick: (): void => this.handleResetFilters()
      })
        .layoutWeight(1);

      IBestButton({
        text: $r("app.string.confirm"),
        type: "primary",
        round: true,
        btnWidth: P100,
        btnHeight: 32,
        onBtnClick: (): void => this.onFilterConfirmClick()
      })
        .layoutWeight(1);
    }
    .width(P100)
    .backgroundColor($r("app.color.bg_white"))
    .padding($r("app.float.space_padding_medium"))
    .border({
      width: { top: 1 },
      color: $r("app.color.border")
    });
  }

  /**
   * 打开筛选下拉
   * @returns {void} 无返回值
   */
  private handleFilterOpen(): void {
    this.syncDraftFilters();
    this.onFiltersClick();
  }

  /**
   * 同步筛选草稿数据
   * @returns {void} 无返回值
   */
  private syncDraftFilters(): void {
    this.draftSelectedCategoryIds = [...this.selectedCategoryIds];
    this.draftMinPrice = this.minPrice;
    this.draftMaxPrice = this.maxPrice;
  }

  /**
   * 切换草稿分类选中状态
   * @param {number} categoryId - 分类 ID
   * @returns {void} 无返回值
   */
  private toggleDraftCategory(categoryId: number): void {
    const index: number = this.draftSelectedCategoryIds.indexOf(categoryId);
    if (index >= 0) {
      this.draftSelectedCategoryIds = this.draftSelectedCategoryIds.filter((id: number): boolean => id !== categoryId);
      return;
    }
    this.draftSelectedCategoryIds = [...this.draftSelectedCategoryIds, categoryId];
  }

  /**
   * 判断草稿分类是否选中
   * @param {number} categoryId - 分类 ID
   * @returns {boolean} 是否选中
   */
  private isDraftCategorySelected(categoryId: number): boolean {
    return this.draftSelectedCategoryIds.includes(categoryId);
  }

  /**
   * 重置筛选条件
   * @returns {void} 无返回值
   */
  private handleResetFilters(): void {
    this.draftSelectedCategoryIds = [];
    this.draftMinPrice = "";
    this.draftMaxPrice = "";
    this.onResetFilters();
  }

  /**
   * 点击确认筛选
   * @returns {void} 无返回值
   */
  private onFilterConfirmClick(): void {
    this.onApplyFilters([...this.draftSelectedCategoryIds], this.draftMinPrice, this.draftMaxPrice);
    this.dropdownMenuController.close();
  }

  /**
   * 获取分类分组可选项
   * @param {CategoryTree} categoryGroup - 分类分组
   * @returns {CategoryTree[]} 可选项列表
   */
  private getCategoryOptions(categoryGroup: CategoryTree): CategoryTree[] {
    if (categoryGroup.children.length > 0) {
      return categoryGroup.children;
    }
    return [categoryGroup];
  }

  /**
   * 判断分类是否有可展示图标
   * @param {CategoryTree} category - 分类信息
   * @returns {boolean} 是否展示图标
   */
  private hasCategoryIcon(category: CategoryTree): boolean {
    if (!category.pic) {
      return false;
    }
    return category.pic.trim().length > 0;
  }

  /**
   * 获取当前排序值
   * @returns {string} 排序值
   */
  private getCurrentSortValue(): string {
    return this.buildSortValue(this.currentSortType, this.currentSortState);
  }

  /**
   * 获取排序下拉选项
   * @returns {IBestDropdownMenuOption[]} 排序选项
   */
  private getSortMenuOptions(): IBestDropdownMenuOption[] {
    return [
      {
        text: $r("app.string.goods_sort_comprehensive"),
        value: this.buildSortValue(SortType.COMPREHENSIVE, SortState.NONE)
      },
      { text: $r("app.string.goods_sort_price_asc"), value: this.buildSortValue(SortType.PRICE, SortState.ASC) },
      { text: $r("app.string.goods_sort_price_desc"), value: this.buildSortValue(SortType.PRICE, SortState.DESC) },
      { text: $r("app.string.goods_sort_sales_asc"), value: this.buildSortValue(SortType.SALES, SortState.ASC) },
      { text: $r("app.string.goods_sort_sales_desc"), value: this.buildSortValue(SortType.SALES, SortState.DESC) }
    ];
  }

  /**
   * 构建排序值
   * @param {SortType} sortType - 排序类型
   * @param {SortState} sortState - 排序状态
   * @returns {string} 排序值
   */
  private buildSortValue(sortType: SortType, sortState: SortState): string {
    if (sortType === SortType.COMPREHENSIVE || sortState === SortState.NONE) {
      return SortType.COMPREHENSIVE;
    }
    return `${sortType}_${sortState}`;
  }

  /**
   * 解析排序值
   * @param {string} value - 排序值
   * @returns {{ type: SortType; state: SortState }} 排序类型与状态
   */
  private parseSortValue(value: string): SortTarget {
    const normalized: string = value.trim();
    if (!normalized || normalized === SortType.COMPREHENSIVE) {
      return { type: SortType.COMPREHENSIVE, state: SortState.NONE };
    }
    const parts: string[] = normalized.split("_");
    if (parts.length !== 2) {
      return { type: SortType.COMPREHENSIVE, state: SortState.NONE };
    }
    const type: SortType = parts[0] === SortType.SALES ? SortType.SALES : SortType.PRICE;
    const state: SortState = parts[1] === SortState.DESC ? SortState.DESC : SortState.ASC;
    return { type, state };
  }

  /**
   * 处理排序选择变化
   * @param {string} value - 选中的排序值
   * @returns {void} 无返回值
   */
  private onSortSelectionChange(value: string): void {
    const target = this.parseSortValue(value);
    this.applySortTarget(target.type, target.state);
  }

  /**
   * 根据目标排序类型与状态触发排序切换
   * @param {SortType} sortType - 目标排序类型
   * @param {SortState} sortState - 目标排序状态
   * @returns {void} 无返回值
   */
  private applySortTarget(sortType: SortType, sortState: SortState): void {
    if (sortType === SortType.COMPREHENSIVE) {
      if (this.currentSortType !== SortType.COMPREHENSIVE || this.currentSortState !== SortState.NONE) {
        this.onSortClick(SortType.COMPREHENSIVE);
      }
      return;
    }

    if (this.currentSortType !== sortType) {
      this.onSortClick(sortType);
      if (sortState === SortState.DESC) {
        this.onSortClick(sortType);
      }
      return;
    }

    if (this.currentSortState === sortState) {
      return;
    }

    if (this.currentSortState === SortState.NONE) {
      this.onSortClick(sortType);
      if (sortState === SortState.DESC) {
        this.onSortClick(sortType);
      }
      return;
    }

    if (this.currentSortState === SortState.ASC && sortState === SortState.DESC) {
      this.onSortClick(sortType);
      return;
    }

    if (this.currentSortState === SortState.DESC && sortState === SortState.ASC) {
      this.onSortClick(sortType);
      this.onSortClick(sortType);
    }
  }
}
