// We can instead take a mutable reference to the bank, and now our interface
// works correctly. However, this is still single threaded. What if we try to
// make this multi-threaded?

struct Bank {
    cash: i32
}

fn deposit(the_bank: &mut Bank, n: i32) {
    the_bank.cash += n;
}

fn withdraw(the_bank: &mut Bank, n: i32) {
    the_bank.cash -= n;
}

fn main() {
    let n = 32;
    let mut the_bank = Bank { cash: 0 };

    deposit(&mut the_bank, 2);
    deposit(&mut the_bank, 2);

    withdraw(&mut the_bank, 2);
    withdraw(&mut the_bank, 2);

    println!("Total: {}", the_bank.cash);
}
