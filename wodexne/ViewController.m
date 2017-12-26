//
//  ViewController.m
//  香奈儿效果
//
//  Created by wkxx on 2017/8/30.
//  Copyright © 2017年 WYL. All rights reserved.
//

#import "ViewController.h"
#import "MoveCell.h"

/*最小值的cell大小*/
#define SCellHeight 80
/*最大值的cell大小*/
#define BCellHeight  [UIScreen mainScreen].bounds.size.width

#define KScreenWidth [UIScreen mainScreen].bounds.size.width

#define KScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableV;

@property (nonatomic, strong) NSMutableArray * dataArray;

//用于辨别松手前的动作 上 下
@property (nonatomic, assign) CGFloat panTranslationY;

@property (nonatomic, weak) UIView * actionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //初始化tableview
    [self createTabel];
    
    
}

- (void)createTabel
{
    self.tableV = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    //设置cell的上下内边距
    self.tableV.contentInset = UIEdgeInsetsMake(BCellHeight - SCellHeight, 0, self.view.frame.size.height - BCellHeight, 0);
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableV];
    [self.tableV registerClass:[MoveCell class] forCellReuseIdentifier:@"cell"];
    
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    pan.delegate = self;
    [view addGestureRecognizer:pan];
    _actionView = view;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClcik:)];
    [view addGestureRecognizer:tap];
    
    [tap requireGestureRecognizerToFail:pan];
}

- (void)tapClcik:(UITapGestureRecognizer*)tapGestureRecognizer
{
    CGPoint point = [tapGestureRecognizer locationInView:_actionView];
    NSInteger index = (self.tableV.contentOffset.y - (SCellHeight - BCellHeight)) / SCellHeight;
    //计算点击的位置
    NSInteger pointIndex;
    if ((point.y - (BCellHeight - SCellHeight)) <= 0) {
        pointIndex = 0;
    }else{
        pointIndex  = (point.y - ((BCellHeight - SCellHeight))) / SCellHeight;
    }
    
    NSInteger location = index + pointIndex;
    
    NSLog(@"点击的位置 -------- %ld", location);
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
    }else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        //获取拖拽手势在self.view 的拖拽姿态
        CGPoint translation = [panGestureRecognizer translationInView:_actionView];
        self.panTranslationY = translation.y;
        NSLog( @"lllll === %f", self.panTranslationY);
        self.tableV.contentOffset = CGPointMake(0, self.tableV.contentOffset.y - translation.y * (SCellHeight / BCellHeight));
        
        [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:_actionView];
    }else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        //结束拖拽的时候检测偏移量
        //最上面的拉伸弹簧效果
        if (self.tableV.contentOffset.y <= SCellHeight - BCellHeight) {
            [self.tableV setContentOffset:CGPointMake(0, SCellHeight - BCellHeight) animated:YES];
            return;
        }
        //最下面的拉伸弹簧效果
        if (self.tableV.contentOffset.y >= SCellHeight - BCellHeight + (8 - 1) * SCellHeight) {
            [self.tableV setContentOffset:CGPointMake(0, (SCellHeight - BCellHeight + (8 - 1) * SCellHeight)) animated:YES];
            return;
        }
        
        //判断当前在最上面是第几个item
        NSInteger index = (self.tableV.contentOffset.y - (SCellHeight - BCellHeight)) / SCellHeight;
        if (self.panTranslationY > 0) {
            //向下滑
            [self.tableV setContentOffset:CGPointMake(0, (SCellHeight - BCellHeight + index * SCellHeight)) animated:YES];
        }else{
            //向上滑
            [self.tableV setContentOffset:CGPointMake(0, (SCellHeight - BCellHeight + (index + 1) * SCellHeight)) animated:YES];
            
        }
    }else{
    
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //改变图片的坐标cell的点击方法不准确所以用手势代替
    NSLog(@"%ld", indexPath.row);
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //滑动的过程中 取出当前第一个item
    NSInteger index = (self.tableV.contentOffset.y - (SCellHeight - BCellHeight)) / SCellHeight;
    // 计算当前item初始位置的偏移量（头部对其）
    CGFloat itemOriginalY = index * SCellHeight + (SCellHeight - BCellHeight);
    //计算偏移量差值
    CGFloat changY = self.tableV.contentOffset.y - itemOriginalY;
    //偏移量转化为上部分的变化量
    CGFloat changBigY = changY * (BCellHeight / (float)SCellHeight);
    //取出当前item 判断偏移是否满足所需变化
    UITableViewCell * cell = [self.tableV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSLog(@"======  %@", cell);
    NSLog(@"------- %f", changBigY);
    
    if (scrollView.contentOffset.y >= SCellHeight - BCellHeight) {
        [[self.tableV visibleCells] enumerateObjectsUsingBlock:^(MoveCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //cell偏移设置
            [obj cellOffsetOnTabelView:self.tableV];
            
        }];
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%.2f", cell.frame.origin.y);
    //cell第一次出现时调用计算偏移量
    MoveCell *getCell = (MoveCell *)cell;
    
    [getCell cellOffsetOnTabelView:tableView];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCellHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoveCell *cell = [self.tableV dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    //给获取的cell赋值图片以及给当前的imagev添加tag值
    [cell cellGetImage:[NSString stringWithFormat:@"%ld.jpeg", indexPath.row + 11]tag:indexPath.row];
    cell.backgroundColor = [UIColor yellowColor];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
