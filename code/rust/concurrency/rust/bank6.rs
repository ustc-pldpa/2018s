// We can solve this problem by using an Arc, or "atomic reference count"
// instead. This allows multiple threads to own a pointer to the same value.
// However, Arc disallows write access to its interior, being read-only.
// So we put a Mutex<Bank> inside the Arc, and even though we have read-only
// access to the Mutex, the Mutex can provide us write access to its interior.

use std::thread;
use std::rc::Rc;
use std::sync::{Arc, Mutex};

struct Bank {
    cash: i32,
}

fn deposit(the_bank: &mut Bank, n: i32) {
    the_bank.cash += n;
}

fn withdraw(the_bank: &mut Bank, n: i32) {
    the_bank.cash -= n;
}

fn customer(mut the_bank: Arc<Mutex<Bank>>) {
    let mut bank_ref = the_bank.lock().unwrap();
    (*bank_ref).cash += 1;
}

fn main() {
    let n = 32;
    let mut the_bank: Arc<Mutex<Bank>> =
        Arc::new(Mutex::new(Bank { cash: 0 }));

    let bank_ref = the_bank.clone();
    thread::spawn(|| {
        customer(bank_ref)
    }).join().unwrap();
}
