import { P100 } from "designsystem";
import { BreakpointState, getBreakpointState } from "state";

/**
 * @file 商品详情轮播图组件
 * @author Joker.X
 */
@ComponentV2
export struct GoodsBanner {
  /**
   * 轮播图数据
   */
  @Param
  bannerList: string[] = [];
  /**
   * 是否自动轮播
   */
  @Param
  autoPlay: boolean = false;
  /**
   * 是否循环轮播
   */
  @Param
  loop: boolean = false;
  /**
   * 图片缩放模式
   */
  @Param
  imageFit: ImageFit = ImageFit.Cover;
  /**
   * 屏幕断点状态
   */
  @Local
  private breakpointState: BreakpointState = getBreakpointState();

  /**
   * 构建轮播图视图
   * @returns {void} 无返回值
   */
  build(): void {
    if (this.bannerList && this.bannerList.length > 0) {
      Swiper() {
        ForEach(this.bannerList, (item: string, index: number): void => {
          Image(item)
            .width(P100)
            .height(P100)
            .objectFit(this.imageFit);
        }, (item: string, index: number): string => `${item}-${index}`);
      }
      .displayCount(1)
      .displayMode(SwiperDisplayMode.STRETCH)
      .indicator(this.getIndicator())
      .autoPlay(this.autoPlay)
      .loop(this.loop)
      .width(P100)
      .height(P100)
      .aspectRatio(1);
    }
  }

  /**
   * 获取轮播图指示器
   * @returns {DotIndicator | boolean} 指示器配置
   */
  private getIndicator(): DotIndicator | boolean {
    if (this.breakpointState.isXS() || this.breakpointState.isSM()) {
      return Indicator.dot()
        .color($r("app.color.bg_purple_light"))
        .selectedColor($r("app.color.primary"));
    }

    return false;
  }
}
