// We saw one way in the previous lecture to have multiple owners of a value,
// the reference-counted pointer. However, if we try to use that here, the
// compiler complains that we can't send the Rc across thread boundaries.
// This is because the reference counter is not atomic, i.e. cannot be safely
// mutated by multiple threads at the same time.

use std::thread;
use std::rc::Rc;

struct Bank {
    cash: i32,
}

fn deposit(the_bank: &mut Bank, n: i32) {
    the_bank.cash += n;
}

fn withdraw(the_bank: &mut Bank, n: i32) {
    the_bank.cash -= n;
}

fn customer(mut the_bank: Rc<Bank>) {
    //deposit(the_bank, 2);
}

fn main() {
    let n = 32;
    let mut the_bank: Rc<Bank> =
        Rc::new(Bank { cash: 0 });

    let bank_ref = the_bank.clone();
    thread::spawn(|| {
        customer(bank_ref)
    }).join().unwrap();

    //println!("Total: {}", the_bank.cash);
}
