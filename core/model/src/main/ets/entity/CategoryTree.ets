import { Category } from "./Category";

/**
 * @file 商品分类树结构
 * @author Joker.X
 */
export class CategoryTree {
  /**
   * ID
   */
  id: number;
  /**
   * 名称
   */
  name: string;
  /**
   * 父ID
   */
  parentId?: number | null;
  /**
   * 排序
   */
  sortNum: number;
  /**
   * 图片
   */
  pic?: string | null;
  /**
   * 状态 0-禁用 1-启用
   */
  status: number;
  /**
   * 创建时间
   */
  createTime?: string | null;
  /**
   * 更新时间
   */
  updateTime?: string | null;
  /**
   * 子分类列表
   */
  children: CategoryTree[];

  constructor(init: CategoryTreeInit) {
    this.id = init.id;
    this.name = init.name;
    this.parentId = init.parentId ?? null;
    this.sortNum = init.sortNum;
    this.pic = init.pic ?? null;
    this.status = init.status;
    this.createTime = init.createTime ?? null;
    this.updateTime = init.updateTime ?? null;
    this.children = init.children ?? [];
  }

  /**
   * 从 Category 转换为 CategoryTree
   */
  static fromCategory(category: Category): CategoryTree {
    return new CategoryTree({
      id: category.id,
      name: category.name,
      parentId: category.parentId ?? null,
      sortNum: category.sortNum,
      pic: category.pic ?? null,
      status: category.status,
      createTime: category.createTime ?? null,
      updateTime: category.updateTime ?? null,
      children: []
    });
  }

  /**
   * 将分类列表转换为树形结构
   * @param {Category[]} categories - 原始分类列表
   * @returns {CategoryTree[]} 树形结构的分类列表
   */
  static buildTree(categories: Category[]): CategoryTree[] {
    if (!categories || categories.length === 0) {
      return [];
    }

    const nestedTrees: CategoryTree[] = CategoryTree.tryBuildTreeFromNested(categories);
    if (nestedTrees.length > 0) {
      return nestedTrees;
    }

    const sortedList: Category[] = [...categories].sort((a: Category, b: Category): number => a.sortNum - b.sortNum);
    const categoryTrees: CategoryTree[] =
      sortedList.map((item: Category): CategoryTree => CategoryTree.fromCategory(item));
    const rootCategories: CategoryTree[] = [];
    const childrenMap: Map<number, CategoryTree[]> = new Map<number, CategoryTree[]>();

    categoryTrees.forEach((categoryTree: CategoryTree): void => {
      const parentId: number | null | undefined = categoryTree.parentId;
      if (parentId === null || parentId === undefined || parentId === 0) {
        rootCategories.push(categoryTree);
        return;
      }
      const children: CategoryTree[] = childrenMap.get(parentId) ?? [];
      children.push(categoryTree);
      childrenMap.set(parentId, children);
    });

    return rootCategories.map((rootCategory: CategoryTree): CategoryTree => {
      return CategoryTree.buildCategoryTree(rootCategory, childrenMap);
    });
  }

  /**
   * 递归构建分类树
   * @param {CategoryTree} categoryTree - 当前分类节点
   * @param {Map<number, CategoryTree[]>} childrenMap - 子分类映射
   * @returns {CategoryTree} 构建完成的分类节点
   */
  private static buildCategoryTree(
    categoryTree: CategoryTree,
    childrenMap: Map<number, CategoryTree[]>
  ): CategoryTree {
    const children: CategoryTree[] = childrenMap.get(categoryTree.id) ?? [];
    if (children.length === 0) {
      return categoryTree;
    }
    categoryTree.children =
      children.map((child: CategoryTree): CategoryTree => CategoryTree.buildCategoryTree(child, childrenMap));
    return categoryTree;
  }

  /**
   * 尝试从已包含 children 的数据中构建树
   * @param {Category[]} categories - 原始分类列表
   * @returns {CategoryTree[]} 构建后的树结构
   */
  private static tryBuildTreeFromNested(categories: Category[]): CategoryTree[] {
    const hasChildren: boolean = categories.some((item: Category): boolean => {
      return (item.children ?? []).length > 0;
    });
    if (!hasChildren) {
      return [];
    }
    return categories.map((item: Category): CategoryTree => CategoryTree.convertNestedNode(item));
  }

  /**
   * 递归转换带 children 的节点
   * @param {Category} category - 原始分类节点
   * @returns {CategoryTree} 转换后的分类树节点
   */
  private static convertNestedNode(category: Category): CategoryTree {
    const node: CategoryTree = CategoryTree.fromCategory(category);
    const children: Category[] = category.children ?? [];
    if (children.length > 0) {
      node.children = children.map((child: Category): CategoryTree => CategoryTree.convertNestedNode(child));
    }
    return node;
  }
}

/**
 * CategoryTree 构造参数类型
 */
export interface CategoryTreeInit {
  id: number;
  name: string;
  parentId?: number | null;
  sortNum: number;
  pic?: string | null;
  status: number;
  createTime?: string | null;
  updateTime?: string | null;
  children?: CategoryTree[];
}
