// A naive transliteration of C into Rust fails because it's unsafe to have
// mutable global variables.

struct Bank {
    cash: i32
}

static mut the_bank: Bank = Bank { cash: 0 };

fn deposit(n: i32) {
    the_bank.cash += n;
}

fn main() {
    let n = 32;
    deposit(2);
}
