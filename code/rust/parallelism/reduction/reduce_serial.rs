fn main() {
    let vec: Vec<i64> = (0..100000).collect();

    let mut sum = 0;
    for i in vec {
        sum += i;
    }

    println!("Sum: {}", sum);
}
