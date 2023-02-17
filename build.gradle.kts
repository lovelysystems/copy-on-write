plugins {
    id("com.lovelysystems.gradle") version ("1.11.3")
}

lovely {
    gitProject()
    dockerProject(
        "lovelysystems/copy-on-write",
    ) {
        from("docker")
    }
}