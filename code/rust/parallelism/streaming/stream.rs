fn main() {
    // Non-streaming
    let v = (0..(1024i64*1024*1024*1024)).into_iter();
    let v1: Vec<i64> = v.collect();
    let mut v2 = Vec::new();
    for x in v1 {
        v2.push(x + 1);
    }
    println!("{}", v2[0]);

    // Streaming
    let v = (0..(1024i64*1024*1024*1024)).into_iter();
    let mut v2 = v.map(|x| x + 1);
    println!("{}", v2.next().unwrap());
}
