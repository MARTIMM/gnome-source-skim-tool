
---
# Administration of GObject

Class **Gnome::GObject::Object** is inheriting from class **Gnome::N::TopLevelClassSupport**

## Class modules

```
GObject                                         Gnome::GObject::Object
|                                               Gnome::GObject::*
├── GskRenderer                                 Renderer
│   ├── GskCairoRenderer                        CairoRenderer
│   ├── GskGLRenderer                           GLRenderer
│   ├── GskNglRenderer
│   ├── GskVulkanRenderer
├── GskGLShader                                 GLShader

GObjectTypeInstance
|                                               GGnome::GObject::*
├── GskRenderNode                               RenderNode
│   ├── GskBlendNode                            BlendNode
│   ├── GskBlurNode                             BlurNode
│   ├── GskBorderNode                           BorderNode
│   ├── GskCairoNode                            CairoNode
│   ├── GskClipNode                             ClipNode
│   ├── GskColorMatrixNode                      ColorMatrixNode
│   ├── GskColorNode                            ColorNode
│   ├── GskConicGradientNode                    ConicGradientNode
│   ├── GskContainerNode                        ContainerNode
│   ├── GskCrossFadeNode                        CrossFadeNode
│   ├── GskDebugNode                            DebugNode
│   ├── GskFillNode
│   ├── GskGLShaderNode                         GLShaderNode
│   ├── GskInsetShadowNode                      InsetShadowNode
│   ├── GskLinearGradientNode                   LinearGradientNode
│   ├── GskMaskNode                             MaskNode
│   ├── GskOpacityNode                          OpacityNode
│   ├── GskOutsetShadowNode                     OutsetShadowNode
│   ├── GskRadialGradientNode                   RadialGradientNode
│   ├── GskRepeatNode                           RepeatNode
│   ├── GskRepeatingLinearGradientNode          RepeatingLinearGradientNode
│   ├── GskRepeatingRadialGradientNode          RepeatingRadialGradientNode
│   ├── GskRoundedClipNode                      RoundedClipNode
│   ├── GskShadowNode                           ShadowNode
│   ├── GskStrokeNode
│   ├── GskSubsurfaceNode
│   ├── GskTextNode                             TextNode
│   ├── GskTextureNode                          TextureNode
│   ├── GskTextureScaleNode                     TextureScaleNode
│   ├── GskTransformNode                        TransformNode

```
Some classes are very new. Not yet found on my system and not in GIR data.Examples: GskFillNode, GskStrokeNode, GskSubsurfaceNode, skVulkanRenderer.

GskNglRenderer seems to be deprecated.

```
GBoxed
|
├── N-ShaderArgsBuilder
├── N-Transform
```

```
Gnome::N::TopLevelClassSupport
|   Gnome::GObject::*
├── T-enums
├── T-glshader
├── T-rendernode
├── T-Transform
├── T-types

```
