trait Foo {
    fn bar(&self);
}

fn call_bar_static<T: Foo>(t: T) {
    t.bar();
}

impl Foo for i32 {
    fn bar(&self) {
        println!("i32");
    }
}

impl Foo for String {
    fn bar(&self) {
        println!("String");
    }
}

fn call_bar_dynamic(t: Box<Foo>) {
    t.bar();
}

fn main() {
    call_bar_static(1);
    call_bar_static("Hi".to_string());
}
