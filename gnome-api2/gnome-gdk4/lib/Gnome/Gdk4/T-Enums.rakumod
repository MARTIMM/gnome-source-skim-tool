# Package: Gdk4, C-Source: enums
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::T-Enums:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant GDK_ACTION_ALL is export = 7;
constant GDK_MODIFIER_MASK is export = 469769999;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GdkAxisUse is export <
  GDK_AXIS_IGNORE GDK_AXIS_X GDK_AXIS_Y GDK_AXIS_DELTA_X GDK_AXIS_DELTA_Y GDK_AXIS_PRESSURE GDK_AXIS_XTILT GDK_AXIS_YTILT GDK_AXIS_WHEEL GDK_AXIS_DISTANCE GDK_AXIS_ROTATION GDK_AXIS_SLIDER GDK_AXIS_LAST 
>;

enum GdkGLError is export <
  GDK_GL_ERROR_NOT_AVAILABLE GDK_GL_ERROR_UNSUPPORTED_FORMAT GDK_GL_ERROR_UNSUPPORTED_PROFILE GDK_GL_ERROR_COMPILATION_FAILED GDK_GL_ERROR_LINK_FAILED 
>;

enum GdkGravity is export <
  GDK_GRAVITY_NORTH_WEST GDK_GRAVITY_NORTH GDK_GRAVITY_NORTH_EAST GDK_GRAVITY_WEST GDK_GRAVITY_CENTER GDK_GRAVITY_EAST GDK_GRAVITY_SOUTH_WEST GDK_GRAVITY_SOUTH GDK_GRAVITY_SOUTH_EAST GDK_GRAVITY_STATIC 
>;

enum GdkMemoryFormat is export <
  GDK_MEMORY_B8G8R8A8_PREMULTIPLIED GDK_MEMORY_A8R8G8B8_PREMULTIPLIED GDK_MEMORY_R8G8B8A8_PREMULTIPLIED GDK_MEMORY_B8G8R8A8 GDK_MEMORY_A8R8G8B8 GDK_MEMORY_R8G8B8A8 GDK_MEMORY_A8B8G8R8 GDK_MEMORY_R8G8B8 GDK_MEMORY_B8G8R8 GDK_MEMORY_R16G16B16 GDK_MEMORY_R16G16B16A16_PREMULTIPLIED GDK_MEMORY_R16G16B16A16 GDK_MEMORY_R16G16B16_FLOAT GDK_MEMORY_R16G16B16A16_FLOAT_PREMULTIPLIED GDK_MEMORY_R16G16B16A16_FLOAT GDK_MEMORY_R32G32B32_FLOAT GDK_MEMORY_R32G32B32A32_FLOAT_PREMULTIPLIED GDK_MEMORY_R32G32B32A32_FLOAT GDK_MEMORY_N_FORMATS 
>;

enum GdkVulkanError is export <
  GDK_VULKAN_ERROR_UNSUPPORTED GDK_VULKAN_ERROR_NOT_AVAILABLE 
>;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GdkAxisFlags is export (
  :GDK_AXIS_FLAG_X(2), :GDK_AXIS_FLAG_Y(4), :GDK_AXIS_FLAG_DELTA_X(8), :GDK_AXIS_FLAG_DELTA_Y(16), :GDK_AXIS_FLAG_PRESSURE(32), :GDK_AXIS_FLAG_XTILT(64), :GDK_AXIS_FLAG_YTILT(128), :GDK_AXIS_FLAG_WHEEL(256), :GDK_AXIS_FLAG_DISTANCE(512), :GDK_AXIS_FLAG_ROTATION(1024), :GDK_AXIS_FLAG_SLIDER(2048)
);

enum GdkDragAction is export (
  :GDK_ACTION_COPY(1), :GDK_ACTION_MOVE(2), :GDK_ACTION_LINK(4), :GDK_ACTION_ASK(8)
);

enum GdkModifierType is export (
  :GDK_SHIFT_MASK(1), :GDK_LOCK_MASK(2), :GDK_CONTROL_MASK(4), :GDK_ALT_MASK(8), :GDK_BUTTON1_MASK(256), :GDK_BUTTON2_MASK(512), :GDK_BUTTON3_MASK(1024), :GDK_BUTTON4_MASK(2048), :GDK_BUTTON5_MASK(4096), :GDK_SUPER_MASK(67108864), :GDK_HYPER_MASK(134217728), :GDK_META_MASK(268435456)
);

