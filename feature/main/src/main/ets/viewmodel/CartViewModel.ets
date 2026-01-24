import { BaseViewModel } from "base";
import { CartRepository } from "data";
import { Cart, CartGoodsSpec } from "model";

/**
 * @file 购物车页面 ViewModel
 * @author Joker.X
 */
@ObservedV2
export default class CartViewModel extends BaseViewModel {
  /**
   * 购物车仓库
   */
  private readonly cartRepository: CartRepository = new CartRepository();
  /**
   * 购物车列表
   */
  @Trace
  cartList: Cart[] = [];
  /**
   * 选中的规格ID集合 (key: goodsId_specId)
   */
  @Trace
  selectedSpecIds: Set<string> = new Set();
  /**
   * 是否正在加载
   */
  @Trace
  isLoading: boolean = false;
  /**
   * 是否处于编辑模式
   */
  @Trace
  isEditing: boolean = false;

  /**
   * 获取选中的商品总数量
   * @returns {number} 选中商品数量
   */
  get selectedCount(): number {
    return this.selectedSpecIds.size;
  }

  /**
   * 获取选中商品的总价
   * @returns {number} 总价（单位：分）
   */
  get totalAmount(): number {
    let total = 0;
    for (const cart of this.cartList) {
      for (const spec of cart.spec) {
        const key = `${cart.goodsId}_${spec.id}`;
        if (this.selectedSpecIds.has(key)) {
          total += spec.price * spec.count;
        }
      }
    }
    return total;
  }

  /**
   * 是否全选
   * @returns {boolean} 是否全选
   */
  get isAllSelected(): boolean {
    if (this.cartList.length === 0) {
      return false;
    }
    for (const cart of this.cartList) {
      for (const spec of cart.spec) {
        const key = `${cart.goodsId}_${spec.id}`;
        if (!this.selectedSpecIds.has(key)) {
          return false;
        }
      }
    }
    return true;
  }

  /**
   * 购物车是否为空
   * @returns {boolean} 是否为空
   */
  get isEmpty(): boolean {
    return this.cartList.length === 0;
  }

  /**
   * 加载购物车数据
   * @returns {Promise<void>} Promise<void>
   */
  async loadCartData(): Promise<void> {
    this.isLoading = true;
    try {
      this.cartList = await this.cartRepository.getAllCarts();
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 切换规格选中状态
   * @param {number} goodsId 商品ID
   * @param {number} specId 规格ID
   * @returns {void} 无返回值
   */
  toggleSpecSelected(goodsId: number, specId: number): void {
    const key = `${goodsId}_${specId}`;
    const newSet = new Set(this.selectedSpecIds);
    if (newSet.has(key)) {
      newSet.delete(key);
    } else {
      newSet.add(key);
    }
    this.selectedSpecIds = newSet;
  }

  /**
   * 判断规格是否选中
   * @param {number} goodsId 商品ID
   * @param {number} specId 规格ID
   * @returns {boolean} 是否选中
   */
  isSpecSelected(goodsId: number, specId: number): boolean {
    const key = `${goodsId}_${specId}`;
    return this.selectedSpecIds.has(key);
  }

  /**
   * 全选/取消全选
   * @returns {void} 无返回值
   */
  toggleSelectAll(): void {
    if (this.isAllSelected) {
      this.selectedSpecIds = new Set();
    } else {
      this.selectAll();
    }
  }

  /**
   * 全选所有商品
   * @returns {void} 无返回值
   */
  private selectAll(): void {
    const newSet = new Set<string>();
    for (const cart of this.cartList) {
      for (const spec of cart.spec) {
        newSet.add(`${cart.goodsId}_${spec.id}`);
      }
    }
    this.selectedSpecIds = newSet;
  }

  /**
   * 更新商品规格数量
   * @param {number} goodsId 商品ID
   * @param {number} specId 规格ID
   * @param {number} count 新数量
   * @returns {Promise<void>} Promise<void>
   */
  async updateSpecCount(goodsId: number, specId: number, count: number): Promise<void> {
    await this.cartRepository.updateCartSpecCount(goodsId, specId, count);
    // 更新本地数据
    for (const cart of this.cartList) {
      if (cart.goodsId === goodsId) {
        for (const spec of cart.spec) {
          if (spec.id === specId) {
            spec.count = count;
            break;
          }
        }
        break;
      }
    }
    // 触发响应式更新
    this.cartList = [...this.cartList];
  }

  /**
   * 删除商品规格
   * @param {number} goodsId 商品ID
   * @param {number} specId 规格ID
   * @returns {Promise<void>} Promise<void>
   */
  async removeSpec(goodsId: number, specId: number): Promise<void> {
    await this.cartRepository.removeSpecFromCart(goodsId, specId);
    // 更新本地数据
    for (let i = 0; i < this.cartList.length; i++) {
      const cart = this.cartList[i];
      if (cart.goodsId === goodsId) {
        cart.spec = cart.spec.filter((s: CartGoodsSpec): boolean => s.id !== specId);
        if (cart.spec.length === 0) {
          this.cartList.splice(i, 1);
        }
        break;
      }
    }
    // 移除选中状态
    const key = `${goodsId}_${specId}`;
    const newSet = new Set(this.selectedSpecIds);
    newSet.delete(key);
    this.selectedSpecIds = newSet;
    // 触发响应式更新
    this.cartList = [...this.cartList];
  }

  /**
   * 删除选中的商品
   * @returns {Promise<void>} Promise<void>
   */
  async deleteSelected(): Promise<void> {
    const selectedKeys = Array.from(this.selectedSpecIds);
    for (const key of selectedKeys) {
      const parts = key.split('_');
      const goodsId = parseInt(parts[0]);
      const specId = parseInt(parts[1]);
      await this.cartRepository.removeSpecFromCart(goodsId, specId);

      // 更新本地数据
      for (let i = 0; i < this.cartList.length; i++) {
        const cart = this.cartList[i];
        if (cart.goodsId === goodsId) {
          cart.spec = cart.spec.filter((s: CartGoodsSpec): boolean => s.id !== specId);
          if (cart.spec.length === 0) {
            this.cartList.splice(i, 1);
          }
          break;
        }
      }
    }
    // 触发响应式更新
    this.cartList = [...this.cartList];
    // 清空选择状态
    this.selectedSpecIds = new Set();
    // 退出编辑模式
    this.isEditing = false;
  }

  /**
   * 结算按钮点击
   * @returns {void} 无返回值
   */
  onSettleClick(): void {
    // TODO: 跳转到订单确认页面
    console.log("结算按钮点击");
  }

  /**
   * 切换编辑模式
   * @returns {void} 无返回值
   */
  toggleEditMode(): void {
    // 清空选择状态
    this.selectedSpecIds = new Set();
    // 切换编辑模式
    this.isEditing = !this.isEditing;
  }
}
