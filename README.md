# ripple_effect

Create a 2D ripple effect using flutter and dart (Still experimental)
[Here is a complete explanation on how it works.](https://medium.com/@mcflyDev/creating-a-2d-ripple-effect-in-flutter-3d73804a2389) 

<p align="center">
<img src="./docs/gifs/waves.gif" width="320" alt="flutter anchored onboarding screen" />
</p>

Or like in example, create a button pushing a wave behind it
<p align="center">
<img src="./docs/gifs/waves2.gif" width="480" alt="flutter anchored onboarding screen" />
</p>

## Add ripple effect on a widget
You can add the ```RippleEffect``` widget over anything. This will screenshot the background and create a ripple effect. 
For a best result add this on a background image. 

```dart
class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RippleEffect(
        pulsations: 2.4,
        dampening: .95,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/mountain.png'), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
```

## Parameters
| Name          | Type                 | Range | Note    |
| ------------- |:--------------------:| -----:|--------:|
| dampening     | double               | 0..1  |1=infinite wave, ideal is nearly 0.9 |
| pulsations    | centered             | 2..infinite | This will add more pulsations as you grow this |
| child         | Widget               |             | put your background or widget you want apply this ripple effect |
| behavior      | RippleEffectBehavior | none, onTouch | none will disable automatic waves on touch. Use a RippleController when using it. | | rippleController     | RippleController          |  | manually trigger a wave |



## RippleController - trigger a wave manually
You can trigger manually using a ```RippleController```. 
see Example/lib/button.dart 

First add the rippleController on your ```RippleEffect``` widget.
```dart
RippleEffect(
    rippleController: rippleController,
    child: Container(
        ...
    ),
),
```

Then call the touch method.
```dart
rippleController.touch(position, 100, radius: 32);
```

## Performances
This is for now fully running on CPU as we don't have access to fragmentShader on flutter for now. 
As you may notice this will make this slower as you run this on big image. 

## Next experiments
* try using flutter FragmentShader (coming soon on flutter) https://github.com/flutter/engine/pull/26996
* rust + dart ffi
* isolates group to share image memory data  