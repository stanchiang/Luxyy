
## Sheriff - by [Gemr](http://www.gemr.com?utm_source=github&utm_medium=open_source&utm_campaign=sheriff)

### Badgify anything.
[![Build Status](https://travis-ci.org/gemr/Sheriff.svg)](https://travis-ci.org/gemr/Sheriff)
[![License](https://img.shields.io/cocoapods/l/Sheriff.svg)](http://doge.mit-license.org) [![Badge w/ Version](https://img.shields.io/cocoapods/v/Sheriff.svg)](https://img.shields.io/cocoapods/v/Sheriff.svg) [![Coverage Status](https://coveralls.io/repos/gemr/Sheriff/badge.svg?branch=master)](https://coveralls.io/r/gemr/Sheriff?branch=master)


![demo](Screenshots/demo.gif)

## Getting started

Add `pod 'Sheriff'` to your podfile, and run `pod install`.

## How easy is it to use?

```objective-c
// Create your badge and add it as a subview to whatever view you want to badgify.
GIBadgeView *badge = [GIBadgeView new];
[myView addSubview:badge];

// Manually set your badge value to whatever number you want.
badge.badgeValue = 5;

// Or increment and decrement to your heart's content.
[badge increment];
[badge decrement];
```

Animations to display and dismiss the badge are handled automatically. Setting the badge value to any positive non-zero integer will result in the badge being shown, and conversely any value less than or equal to zero results in the badge being dismissed.

Easy, huh?

## Can I customize it?

You sure can...

```objective-c
badge.font = [UIFont fontWithName:@"OpenSans-Semibold" size:18];
badge.textColor = [UIColor whiteColor];
badge.backgroundColor = [UIColor colorWithRed:49/255.0 green:69/255.0 blue:122/255.0 alpha:1.0];
```

![demo](Screenshots/demo1.gif)

If you want to offset the badge because it's not placed quite right:

```objective-c
badge.topOffset = 10;   // Moves the badge down 10 points.
badge.rightOffset = 10; // Moves the badge right 10 points.
```

## License

The source is made available under the MIT license.
