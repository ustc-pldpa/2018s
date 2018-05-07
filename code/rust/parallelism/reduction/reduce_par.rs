use std::thread;
use std::sync::Arc;

const NUM_WORKERS: usize = 8;

fn main() {
    let vec: Arc<Vec<i64>> = Arc::new((0..100000).collect());

    let chunk_size = vec.len() / NUM_WORKERS;

    let handles: Vec<thread::JoinHandle<i64>> =
        (0..NUM_WORKERS).into_iter().map(|i| {
        let vec_ref = vec.clone();
        thread::spawn(move || {
            let mut sum = 0;
            for j in (i * chunk_size)..((i + 1) * chunk_size) {
                sum += vec_ref[j];
            }
            sum
        })
    });

    let mut final_sum = 0;
    for handle in handles {
        final_sum += handle.join().unwrap();
    }

    println!("Sum: {}", final_sum);
}
