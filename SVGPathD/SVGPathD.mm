//
//  SVGPathD.m
//  SVGPathD
//
//  Created by Ushio on 2014/12/20.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "SVGPathD.h"

#include <array>
#include <unordered_map>

namespace
{
    template <typename T>
    using CGPathPointer = std::shared_ptr<typename std::remove_pointer<T>::type>;
    
    template <class T>
    CGPathPointer<T> CGPathPointerMake(T path) {
        return CGPathPointer<T>(path, CGPathRelease);
    }
    
    template <std::size_t N>
    bool scan_argument(NSScanner *scanner, std::array<double, N>& arguments)
    {
        for(int i = 0 ; i < N ; ++i)
        {
            if([scanner scanDouble:arguments.data() + i] == NO)
            {
                return false;
            }
        }
        return true;
    }
    
    CGPoint symmetryPoint(CGPoint origin, CGPoint point)
    {
        CGPoint po = CGPointMake(origin.x - point.x, origin.y - point.y);
        return CGPointMake(origin.x + po.x, origin.y + po.y);
    }
    
    struct CommandHandleResult
    {
        static CommandHandleResult Succeeded(CGPoint lastControlPoint) {
            CommandHandleResult result;
            result.isFailed = false;
            result.lastControlPoint = lastControlPoint;
            return result;
        }
        static CommandHandleResult Failed() {
            return CommandHandleResult();
        }
        bool isFailed = false;
        CGPoint lastControlPoint = CGPointZero;
    };
    
    CommandHandleResult handle_command_M(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        std::array<double, 2> arguments;
        if(scan_argument(scanner, arguments) == false)
        {
            return CommandHandleResult::Failed();
        }
        
        double px = arguments[0];
        double py = arguments[1];
        
        if(isRelative)
        {
            CGPoint current = CGPathGetCurrentPoint(path);
            CGPathMoveToPoint(path, NULL, current.x + px, current.y + py);
        }
        else
        {
            CGPathMoveToPoint(path, NULL, px, py);
        }
        return CommandHandleResult::Succeeded(CGPathGetCurrentPoint(path));
    }
    CommandHandleResult handle_command_L(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        std::array<double, 2> arguments;
        if(scan_argument(scanner, arguments) == false)
        {
            return CommandHandleResult::Failed();
        }
        
        double px = arguments[0];
        double py = arguments[1];
        
        if(isRelative)
        {
            CGPoint current = CGPathGetCurrentPoint(path);
            CGPathAddLineToPoint(path, NULL, current.x + px, current.y + py);
        }
        else
        {
            CGPathAddLineToPoint(path, NULL, px, py);
        }
        
        return CommandHandleResult::Succeeded(CGPathGetCurrentPoint(path));
    }
    CommandHandleResult handle_command_H(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        std::array<double, 1> arguments;
        if(scan_argument(scanner, arguments) == false)
        {
            return CommandHandleResult::Failed();
        }
        
        double px = arguments[0];
        
        CGPoint current = CGPathGetCurrentPoint(path);
        CGPathAddLineToPoint(path, NULL, (isRelative ? current.x : 0.0) + px, current.y);
        
        return CommandHandleResult::Succeeded(CGPathGetCurrentPoint(path));
    }
    CommandHandleResult handle_command_V(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        std::array<double, 1> arguments;
        if(scan_argument(scanner, arguments) == false)
        {
            return CommandHandleResult::Failed();
        }
        
        double py = arguments[0];
        
        CGPoint current = CGPathGetCurrentPoint(path);
        CGPathAddLineToPoint(path, NULL, current.x, (isRelative ? current.y : 0.0) + py);
        
        return CommandHandleResult::Succeeded(CGPathGetCurrentPoint(path));
    }
    
    CommandHandleResult handle_command_C(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        std::array<double, 6> arguments;
        if(scan_argument(scanner, arguments) == false)
        {
            return CommandHandleResult::Failed();
        }
        
        double cp1x = arguments[0];
        double cp1y = arguments[1];
        double cp2x = arguments[2];
        double cp2y = arguments[3];
        double px = arguments[4];
        double py = arguments[5];
        
        CGPoint lastControlPoint = CGPointZero;
        if(isRelative)
        {
            CGPoint current = CGPathGetCurrentPoint(path);
            lastControlPoint = CGPointMake(current.x + cp2x, current.y + cp2y);
            CGPathAddCurveToPoint(path, NULL,
                                  current.x + cp1x, current.y + cp1y,
                                  lastControlPoint.x, lastControlPoint.y,
                                  current.x + px, current.y + py);
        }
        else
        {
            lastControlPoint = CGPointMake(cp2x, cp2y);
            CGPathAddCurveToPoint(path, NULL,
                                  cp1x, cp1y,
                                  lastControlPoint.x, lastControlPoint.y,
                                  px, py);
        }
        
        return CommandHandleResult::Succeeded(lastControlPoint);
    }
    CommandHandleResult handle_command_S(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        std::array<double, 4> arguments;
        if(scan_argument(scanner, arguments) == false)
        {
            return CommandHandleResult::Failed();
        }
        CGPoint current = CGPathGetCurrentPoint(path);
        
        CGPoint cp1 = symmetryPoint(current, previousControlPoint);
        double cp2x = arguments[0];
        double cp2y = arguments[1];
        double px = arguments[2];
        double py = arguments[3];
        
        CGPoint lastControlPoint = CGPointZero;
        if(isRelative)
        {
            
            lastControlPoint = CGPointMake(current.x + cp2x, current.y + cp2y);
            CGPathAddCurveToPoint(path, NULL,
                                  cp1.x, cp1.y,
                                  lastControlPoint.x, lastControlPoint.y,
                                  current.x + px, current.y + py);
        }
        else
        {
            lastControlPoint = CGPointMake(cp2x, cp2y);
            CGPathAddCurveToPoint(path, NULL,
                                  cp1.x, cp1.y,
                                  lastControlPoint.x, lastControlPoint.y,
                                  px, py);
        }
        
        return CommandHandleResult::Succeeded(lastControlPoint);
    }
    CommandHandleResult handle_command_Q(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        std::array<double, 4> arguments;
        if(scan_argument(scanner, arguments) == false)
        {
            return CommandHandleResult::Failed();
        }
        
        double cpx = arguments[0];
        double cpy = arguments[1];
        double px = arguments[2];
        double py = arguments[3];
        
        CGPoint lastControlPoint = CGPointZero;
        if(isRelative)
        {
            CGPoint current = CGPathGetCurrentPoint(path);
            lastControlPoint = CGPointMake(current.x + cpx, current.y + cpy);
            CGPathAddQuadCurveToPoint(path, NULL,
                                      current.x + cpx, current.y + cpy,
                                      current.x + px, current.y + py);
        }
        else
        {
            lastControlPoint = CGPointMake(cpx, cpy);
            CGPathAddQuadCurveToPoint(path, NULL,
                                      lastControlPoint.x, lastControlPoint.y,
                                      px, py);
        }
        
        return CommandHandleResult::Succeeded(lastControlPoint);
    }
    CommandHandleResult handle_command_T(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        std::array<double, 4> arguments;
        if(scan_argument(scanner, arguments) == false)
        {
            return CommandHandleResult::Failed();
        }
        
        CGPoint current = CGPathGetCurrentPoint(path);
        
        CGPoint cp = symmetryPoint(current, previousControlPoint);
        double px = arguments[0];
        double py = arguments[1];
        
        CGPoint lastControlPoint = cp;
        if(isRelative)
        {
            CGPathAddQuadCurveToPoint(path, NULL,
                                      current.x + cp.x, current.y + cp.y,
                                      current.x + px, current.y + py);
        }
        else
        {
            CGPathAddQuadCurveToPoint(path, NULL,
                                      cp.x, cp.y,
                                      px, py);
        }
        
        return CommandHandleResult::Succeeded(lastControlPoint);
    }
    
    
    CommandHandleResult handle_command_Z(NSScanner *scanner, bool isRelative, CGMutablePathRef path, CGPoint previousControlPoint)
    {
        CGPathCloseSubpath(path);
        return CommandHandleResult::Succeeded(CGPathGetCurrentPoint(path));
    }
    
    NSCharacterSet *ignoreCharacterSet()
    {
        NSMutableCharacterSet *charactorSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        [charactorSet addCharactersInString:@","];
        return charactorSet;
    }
    
    CGPathPointer<CGPathRef> build(NSString *pathd)
    {
        NSCharacterSet *commands = [NSCharacterSet characterSetWithCharactersInString:@"MmLlCcVvHhSsQqTtZz"];
        NSScanner *scanner = [NSScanner scannerWithString:pathd];
        [scanner setCharactersToBeSkipped:ignoreCharacterSet()];
        
        CGPathPointer<CGMutablePathRef> constuctionPath = CGPathPointerMake(CGPathCreateMutable());
        
        static const std::unordered_map<char, CommandHandleResult(*)(NSScanner *, bool, CGMutablePathRef, CGPoint)> commandHandlers = {
            {'M', handle_command_M},
            {'L', handle_command_L},
            {'H', handle_command_H},
            {'V', handle_command_V},
            {'C', handle_command_C},
            {'S', handle_command_S},
            {'Q', handle_command_Q},
            {'T', handle_command_T},
            {'Z', handle_command_Z}
        };
        
        CGPoint lastControlPoint = CGPointZero;
        for(;;)
        {
            __autoreleasing NSString *commandString = nil;
            if([scanner scanCharactersFromSet:commands intoString:&commandString] == NO)
            {
                break;
            }
            
            char command = [commandString UTF8String][0];
            bool isRelative = islower(command);
            char commandUpper = toupper(command);
            
            auto it_handler = commandHandlers.find(commandUpper);
            if(it_handler != commandHandlers.end())
            {
                CommandHandleResult result = (it_handler->second)(scanner, isRelative, constuctionPath.get(), lastControlPoint);
                if(result.isFailed)
                {
                    return CGPathPointer<CGPathRef>();
                }
                lastControlPoint = result.lastControlPoint;
            }
            else
            {
                return CGPathPointer<CGPathRef>();
            }
        }
        
        return constuctionPath;
    }
}

@implementation SVGPathD
{
    CGPathPointer<CGPathRef> _path;
}
- (instancetype)initWithPathD:(NSString *)pathD
{
    if(self = [super init])
    {
        _path = build(pathD);
    }
    return self;
}
- (CGPathRef)CGPath
{
    return _path.get();
}
@end
