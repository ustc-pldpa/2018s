// Now we have a fully functional API! But still, this is only one thread.

use std::thread;
use std::rc::Rc;
use std::sync::{Arc, Mutex};

struct Bank {
    cash: i32,
}

fn deposit(the_bank: &Arc<Mutex<Bank>>, n: i32) {
    let mut bank_ref = the_bank.lock().unwrap();
    (*bank_ref).cash += n;
}

fn withdraw(the_bank: &Arc<Mutex<Bank>>, n: i32) {
    let mut bank_ref = the_bank.lock().unwrap();
    (*bank_ref).cash -= n;
}

fn customer(the_bank: Arc<Mutex<Bank>>) {
    for _ in 0..100 {
        deposit(&the_bank, 2);
    }

    for _ in 0..100 {
        withdraw(&the_bank, 2);
    }
}

fn main() {
    let n = 32;
    let the_bank: Arc<Mutex<Bank>> =
        Arc::new(Mutex::new(Bank { cash: 0 }));

    let bank_ref = the_bank.clone();
    thread::spawn(|| {
        customer(bank_ref)
    }).join().unwrap();

    println!("Total: {}", the_bank.lock().unwrap().cash);
}
