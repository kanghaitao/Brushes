//
//  CZViewImpl.cpp
//  HYDrawing
//
//  Created by CharlyZhang on 15/8/12.
//  Copyright (c) 2015年 Founder. All rights reserved.
//

#include "CZViewImpl.h"
#include "graphic/glDef.h"
#include "CZUtil.h"
#include "CZActiveState.h"
#include "tool/CZFreehandTool.h"
#import "WDColor.h"


NSString *CZActivePaintColorDidChange = @"CZActivePaintColorDidChange";

////////////////////CanvasView////////////////////
CZViewImpl::CZViewImpl(const CZRect rect)
{
    realView = [[CanvasView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
}

CZViewImpl::~CZViewImpl() {}
void CZViewImpl::setPaiting(CZPainting* p) { realView.ptrPainting = p;}
void CZViewImpl::draw() { [realView drawView];}

////////////////////CanvasView////////////////////
@interface CanvasView()
{
    CZMat4 projMat;
    EAGLContext *context;               ///
}

@property (nonatomic, assign) CZFbo* fbo;

@end

@implementation CanvasView

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.multipleTouchEnabled = YES;
    self.contentMode = UIViewContentModeCenter;
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.exclusiveTouch = YES;
    self.opaque = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1];
    
    // configure the layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat, nil];
    
    CGSize size = frame.size;
    projMat.SetOrtho(0,size.width, 0, size.height, -1.0f, 1.0f);
    
    glEnable(GL_TEXTURE_2D);        /// will emit gl error, but cause showing nothing if be deleted
    CZCheckGLError();
    glActiveTexture(GL_TEXTURE0);
    
    
    [self configureGestrues];
    
    return self;
}

- (void)dealloc
{
    [EAGLContext setCurrentContext:context];
    delete _fbo;
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
}

#pragma mark - Properties

- (CZFbo*)fbo
{
    if (!_fbo && context) {
        [EAGLContext setCurrentContext:context];
        _fbo = new CZFbo;
    }
    
    return _fbo;
}

- (void)setPtrPainting:(CZPainting *)ptrPainting
{
    _ptrPainting = ptrPainting;
    if (_ptrPainting) {
        context = (__bridge EAGLContext*) self.ptrPainting->getGLContext()->getRealContext();
    }
    else
        context = nil;
        
}

#pragma mark - Geusture
- (void)configureGestrues
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
}


- (void)handlePanGesture:(UIPanGestureRecognizer*)sender
{
    LOG_DEBUG("pan\t");
    CZActiveState *activeState = CZActiveState::getInstance();
    
    if (activeState->colorFillMode || activeState->colorPickMode) return;
    
    if (self.ptrPainting->shouldPreventPaint()) {
        CZLayer *layer = self.ptrPainting->getActiveLayer();
        if (layer->isLocked())          [self.delegate showMessageView:kLocked];
        else if(!layer->isVisible())    [self.delegate showMessageView:kInvisible];
        return;
    }
    
    CGPoint p = [sender locationInView:sender.view];
    p.y = self.bounds.size.height - p.y;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        activeState->getActiveTool()->moveBegin(p.x,p.y);
    }
    else if (sender.state == UIGestureRecognizerStateChanged){
        CGPoint velocity = [sender velocityInView:sender.view];
        CZ2DPoint zeroPoint; CZ2DPoint v(velocity.x,velocity.y);
        float   speed = zeroPoint.distanceTo2DPoint(v) / 1000.0f; // pixels/millisecond
        LOG_DEBUG("speed is %f\n", speed);
        activeState->getActiveTool()->moving(p.x, p.y, speed);
    }
    else if (sender.state == UIGestureRecognizerStateEnded){
        activeState->getActiveTool()->moveEnd(p.x, p.y);
    }
    else if (sender.state == UIGestureRecognizerStateCancelled) {
        LOG_DEBUG("gesture canceled!\n");
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer*)sender
{
    LOG_DEBUG("tap\n");
    if (self.ptrPainting->shouldPreventPaint()) {
        CZLayer *layer = self.ptrPainting->getActiveLayer();
        if (layer->isLocked())          [self.delegate showMessageView:kLocked];
        else if(!layer->isVisible())    [self.delegate showMessageView:kInvisible];
        return;
    }
    
    CGPoint p = [sender locationInView:sender.view];
    p.y = self.bounds.size.height - p.y;
    
    CZActiveState *activeState = CZActiveState::getInstance();
    
    if (activeState->colorFillMode) {
        CZLayer *layer = self.ptrPainting->getActiveLayer();
        CZColor color = activeState->getPaintColor();
        CZ2DPoint location = CZ2DPoint(p.x,p.y);
        layer->fill(color, location);
        [self drawView];
    }
    else if (activeState->colorPickMode) {
//        CZLayer *layer = self.ptrPainting->getActiveLayer();
//        CZColor color = activeState->getPaintColor();
//        CZ2DPoint location = CZ2DPoint(p.x,p.y);
//        layer->fill(color, location);
//        [self drawView];
        WDColor *black = [WDColor blackColor];
        CZColor black1 = CZColor::blackColor();
        activeState->setPaintColor(black1);
        NSDictionary *userInfo = @{@"pickedColor": black};
        [[NSNotificationCenter defaultCenter] postNotificationName:CZActivePaintColorDidChange object:nil userInfo:userInfo];
    }
    
}

#pragma mark - Draw
- (void) drawView
{
    if (!self.ptrPainting) {
        LOG_ERROR("ptrPainting is NULL!]\n");
        return ;
    }
    
    [EAGLContext setCurrentContext:context];
    self.fbo->begin();
    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT );
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    self.ptrPainting->blit(projMat);
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.fbo->getRenderBufferId());
    [context presentRenderbuffer:GL_RENDERBUFFER];
    LOG_DEBUG("drawView\n");
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    projMat.SetOrtho(0,size.width, 0, size.height, -1.0f, 1.0f);
    [EAGLContext setCurrentContext:context];
    if(self.fbo)
        self.fbo->setRenderBufferWithContext((__bridge void*)context, (__bridge void*)self.layer);
    [self drawView];
}

@end


