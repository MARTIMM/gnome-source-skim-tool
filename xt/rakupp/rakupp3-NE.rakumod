use v6.d;
use NativeCall;

unit class Gnome::Glib::T-error;

class N-Error is export is repr('CStruct') {
  has uint32 $.domain;
  has int32 $.code;
  has Str $.message;

  submethod BUILD (
    uint32 :$!domain, int32 :$!code, Str :$message, 
  ) {
    $!message := $message;
  }

  method COERCE ( $no --> N-Error ) {
    note "Coercing from {$no.^name} to ", self.^name;
    nativecast( N-Error, $no)
  }
}
