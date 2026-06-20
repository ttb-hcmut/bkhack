#import "/article": *

#let vn(s) = {
  if s == [Shell] or s == [The shell] {
    [Ngôn ngữ vỏ]
  } else if s == [shell] {
    [ngôn ngữ vỏ]
  } else if s == [Kernel] or s == [The kernel] {
    [Hệ thống nhân]    
  } else if s == [kernel] {
    [hệ thống nhân]    
  }
}

The _shell_ (_#vn[shell]_) is #lorem(30)

The _kernel_ (_#vn[kernel]_) is #lorem(30)

// vi: set nowrap:
