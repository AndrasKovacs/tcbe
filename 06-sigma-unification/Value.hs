
module Value where

import Common
import Syntax

data Spine
  = SNil
  | SApp Spine ~Val Icit
  | SProj1 Spine
  | SProj2 Spine
  | SProjField Spine Name Int
  deriving Show

reverseSpine :: Spine -> Spine
reverseSpine = go SNil where
  go acc SNil                = acc
  go acc (SApp sp t i)       = go (SApp acc t i) sp
  go acc (SProj1 sp)         = go (SProj1 acc) sp
  go acc (SProj2 sp)         = go (SProj2 acc) sp
  go acc (SProjField sp x n) = go (SProjField acc x n) sp

spineLen :: Spine -> Int
spineLen = go 0 where
  go acc SNil                = acc
  go acc (SApp sp _ _)       = go (acc + 1) sp
  go acc (SProj1 sp)         = go (acc + 1) sp
  go acc (SProj2 sp)         = go (acc + 1) sp
  go acc (SProjField sp _ _) = go (acc + 1) sp

type Env     = [Val]
data Closure = Close Env Tm | Fun (Val -> Val)     -- first-order closure: Close | HOAS closure: Fun
type VTy     = Val                                 -- currying convenient + efficient with HOAS

instance Show Closure where
  show _ = "<cl>"

data Val
  = VFlex MetaVar Spine
  | VRigid Lvl Spine
  | VLam Name Icit {-# unpack #-} Closure
  | VPi Name Icit ~VTy {-# unpack #-} Closure
  | VSg Name ~VTy {-# unpack #-} Closure
  | VPair ~Val ~Val
  | VU
  deriving Show

pattern VVar :: Lvl -> Val
pattern VVar x = VRigid x SNil

pattern VMeta :: MetaVar -> Val
pattern VMeta m = VFlex m SNil
