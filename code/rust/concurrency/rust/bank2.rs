// We can change this by having bank not be global, but just making it a normal
// owned type is a problem since we can only make one deposit!

struct Bank {
    cash: i32
}

fn deposit(mut the_bank: Bank, n: i32) {
    the_bank.cash += n;
}

fn main() {
    let n = 32;
    let mut the_bank = Bank { cash: 0 };

    deposit(the_bank, 2);
    deposit(the_bank, 2);
}
