// RUN: %clang_cc1 -load %llvmshlibdir/dorofeev_i_cast_replace_ClangAST%pluginext -plugin cast_replace_plugin -fsyntax-only %s 2>&1 | FileCheck %s

// --- Базовые типы ---
void test_primitive_casts() {
    int a = 5;
    
    // CHECK: double b = static_cast<double>(a);
    double b = (double)a;

    // CHECK: int *p = reinterpret_cast<int *>(a);
    int *p = (int *)a;

    const int c = 10;
    
    // CHECK: int *q = const_cast<int *>(&c);
    int *q = (int *)&c;
}

// --- Вспомогательные классы и структуры для тестов ---
struct Point {
    int x;
    int y;
};

struct DataBlock {
    float values[4];
};

class Base {
public:
    virtual ~Base() {}
};

class Derived : public Base {
public:
    int id;
};

// --- Нетривиальные типы ---
void test_custom_types() {
    Point pt = {10, 20};

    // 1. Каст между несвязанными структурами 
    // Ожидаем: reinterpret_cast (в AST CK_BitCast)
    // CHECK: DataBlock *data = reinterpret_cast<DataBlock *>(&pt);
    DataBlock *data = (DataBlock *)&pt;

    // 2. Каст вверх по иерархии наследования (Upcast)
    // Ожидаем: static_cast (в AST CK_DerivedToBase)
    Derived derived_obj;
    // CHECK: Base *base_ptr = static_cast<Base *>(&derived_obj);
    Base *base_ptr = (Base *)&derived_obj;

    // 3. Каст вниз по иерархии (Downcast)
    // Ожидаем: static_cast (в AST CK_BaseToDerived)
    Base *b_ptr = new Derived();
    // CHECK: Derived *d_ptr = static_cast<Derived *>(b_ptr);
    Derived *d_ptr = (Derived *)b_ptr;

    // 4. Снятие константности с пользовательского типа
    // Ожидаем: const_cast (в AST CK_NoOp с изменением квалификаторов)
    const Point const_pt = {0, 0};
    // CHECK: Point *mut_pt = const_cast<Point *>(&const_pt);
    Point *mut_pt = (Point *)&const_pt;
}