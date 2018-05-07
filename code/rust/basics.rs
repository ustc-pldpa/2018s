#[allow(unused_variables)]
#[allow(dead_code)]
fn main() {
    // Basic variable binding
    let x: i32 = 1;
    println!("x: {}", x);

    // Type inference
    let x = x + 1 + 2 + 3;
    // x = 0; immutability by default, can't do this

    // Lexical scoping
    {
        let x = 100;
        println!("Inside block: {}", x);
    }
    println!("Outside block: {}", x);

    // Mutability with the mut keyword
    let mut y = 0;
    y = y + 1;
    println!("y: {}", y);

    // String types
    let s: String = "Hello world".into();
    println!("s: {}", s);

    // Tuples
    let t: (i32, f64) = (1, 3.14);
    let (_, f) = t;  // destructing assignment
    println!("t: {:?}, f: {}", t, f);

    // Structs
    struct Point {
        x: i32,
        y: i32
    }

    let origin: Point = Point { x: 0, y: 0 };
    println!("x: {}, y: {}", origin.x, origin.y);

    // Enums
    enum Direction {
        North,
        South,
        East,
        West
    }

    let d: Direction = Direction::North;

    #[derive(Debug)]
    enum Tree {
        Node(Box<Tree>, i32, Box<Tree>),
        Leaf
    }

    let tree = Tree::Node(
        Box::new(Tree::Leaf), 2, Box::new(
            Tree::Node(Box::new(Tree::Leaf), 0, Box::new(Tree::Leaf))));
    println!("tree: {:?}", tree);

    // Match statements
    match tree {
        Tree::Node(_, n, _) => println!("Node: {}", n),
        Tree::Leaf => println!("Leaf")
    };

    // Fixed-size arrays
    let mut l: [i32; 3] = [1, 2, 3];
    l[0] = 4;
    println!("l: {:?}", l);

    // For loops
    for i in l.iter() {
        println!("{}", i);
    }

    // If statements
    if l[0] == 4 {
        println!("If branch");
    } else {
        println!("Else branch");
    }

    // Inline if-statement (like OCaml)
    l[1] = if l[0] == 4 { 1 } else { 2 };

    // Functions
    let x = 1;
    let y = add_one(x);
    println!("{}", x + y);

    // Generics
    enum MyOption<T> {
        MySome(T),
        MyNone
    }

    let x: MyOption<i32> = MyOption::MySome(3);
    match x {
        MyOption::MySome(y) => println!("x: Some {}", y),
        MyOption::MyNone => println!("x: None")
    };
}

// Basic functions
fn add_one(x: i32) -> i32 {
    x + 1
    // or return x + 1;
}

fn add_suffix(x: String) -> String {
    x + "_foo"
}

// Generic function (T is a type parameter)
fn id<T>(x: T) -> T{
    x
}

// Object-oriented programming with structs
#[derive(Debug)]
struct Point {
    x: i32,
    y: i32
}

// C-style OOP
fn point_add(a: Point, b: Point) -> Point {
    Point { x: a.x + b.x, y: a.y + b.y }
}

// Java-style OOP
impl Point {
    pub fn new(x: i32, y: i32) -> Point {
        Point { x, y }
    }

    pub fn add(&self, other: Point) -> Point {
        Point { x: self.x + other.x, y: self.y + other.y }
    }

    pub fn set_x(&mut self, x: i32) {
        self.x = x;
    }
}

fn example_point_usage() {
    let mut p1 = Point::new(5, 2);
    p1.set_x(10);
    let p2 = Point::new(3, 1);
    println!("{:?}", p1.add(p2));
}

// Traits define interfacse
trait ToString {
    fn to_string(&self) -> String;
}

impl ToString for Point {
    fn to_string(&self) -> String {
        "Hello".into()
    }
}

// Generic functions use traits to define capabilities of generic type
fn print_thing<T: ToString>(t: T) {
    println!("Thing: {}", t.to_string());
}

trait Addable<T> {
    fn add(&self, other: T) -> T;
}

impl Addable<Point> for Point {
    fn add(&self, other: Point) -> Point {
        other
    }
}

// Can compose two traits together
fn print_2things<T: ToString + Addable<T>>(t1: T, t2: T) {
    println!("Thing 1: {}, Thing 2: {}, Things added: {}",
             t1.to_string(), t2.to_string(), t1.add(t2).to_string());
}
