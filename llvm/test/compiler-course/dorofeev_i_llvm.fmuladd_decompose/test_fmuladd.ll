; RUN: opt -load-pass-plugin %llvmshlibdir/dorofeev_i_llvm.fmuladd_decompose_LLVM_IR%pluginext \
; RUN: -passes=fmuladd-decompose -S %s | FileCheck %s

declare float @llvm.fmuladd.f32(float, float, float)
declare double @llvm.fmuladd.f64(double, double, double)
declare <4 x float> @llvm.fmuladd.v4f32(<4 x float>, <4 x float>, <4 x float>)

; --- Тест с float ---
; CHECK-LABEL: define float @test_fmuladd_f32(
define float @test_fmuladd_f32(float %a, float %b, float %c) {
; CHECK-NEXT:    [[MUL:%.*]] = fmul float %a, %b
; CHECK-NEXT:    [[ADD:%.*]] = fadd float [[MUL]], %c
; CHECK-NEXT:    ret float [[ADD]]
  %res = call float @llvm.fmuladd.f32(float %a, float %b, float %c)
  ret float %res
}

; --- Тест с double ---
; CHECK-LABEL: define double @test_fmuladd_f64(
define double @test_fmuladd_f64(double %a, double %b, double %c) {
; CHECK-NEXT:    [[MUL:%.*]] = fmul double %a, %b
; CHECK-NEXT:    [[ADD:%.*]] = fadd double [[MUL]], %c
; CHECK-NEXT:    ret double [[ADD]]
  %res = call double @llvm.fmuladd.f64(double %a, double %b, double %c)
  ret double %res
}

; --- Тест с SIMD ---
; CHECK-LABEL: define <4 x float> @test_fmuladd_vector(
define <4 x float> @test_fmuladd_vector(<4 x float> %a, <4 x float> %b, <4 x float> %c) {
; CHECK-NEXT:    [[MUL:%.*]] = fmul <4 x float> %a, %b
; CHECK-NEXT:    [[ADD:%.*]] = fadd <4 x float> [[MUL]], %c
; CHECK-NEXT:    ret <4 x float> [[ADD]]
  %res = call <4 x float> @llvm.fmuladd.v4f32(<4 x float> %a, <4 x float> %b, <4 x float> %c)
  ret <4 x float> %res
}

; --- Тест с fast-math ---
; CHECK-LABEL: define float @test_fmuladd_fast_math(
define float @test_fmuladd_fast_math(float %a, float %b, float %c) {
; CHECK-NEXT:    [[MUL:%.*]] = fmul fast float %a, %b
; CHECK-NEXT:    [[ADD:%.*]] = fadd fast float [[MUL]], %c
; CHECK-NEXT:    ret float [[ADD]]
  %res = call fast float @llvm.fmuladd.f32(float %a, float %b, float %c)
  ret float %res
}

; --- Тест с константами ---
; CHECK-LABEL: define float @test_fmuladd_constants(
define float @test_fmuladd_constants(float %a) {
; CHECK-NEXT:    [[MUL:%.*]] = fmul float %a, 2.000000e+00
; CHECK-NEXT:    [[ADD:%.*]] = fadd float [[MUL]], 3.000000e+00
; CHECK-NEXT:    ret float [[ADD]]
  %res = call float @llvm.fmuladd.f32(float %a, float 2.0, float 3.0)
  ret float %res
}