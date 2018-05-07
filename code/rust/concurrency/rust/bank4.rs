// Oh no! Compiler error. We can't pass normal Rust references between threads,
// as that might cause a dangling pointer error.

use std::thread;

struct Bank {
    cash: i32
}

fn deposit(the_bank: &mut Bank, n: i32) {
    the_bank.cash += n;
}

fn withdraw(the_bank: &mut Bank, n: i32) {
    the_bank.cash -= n;
}

fn customer(the_bank: &mut Bank) {
    deposit(the_bank, 2);
}

fn main() {
    let n = 32;
    let mut the_bank = Bank { cash: 0 };

    thread::spawn(|| {
        customer(&mut the_bank)
    }).join().unwrap();

    println!("Total: {}", the_bank.cash);
}
