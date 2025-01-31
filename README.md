# MPBasic

MPBasic is a comprehensive BASIC interpreter designed for 32-bit microcontrollers, emphasizing ease of use and rapid software development. It allows developers to write, test, and modify code efficiently, making it ideal for embedded systems and hardware projects.

## Features

- **Interpreter-Based Execution**: MPBasic decodes each statement during runtime, eliminating the need for a separate compiler or operating system. This approach facilitates quick testing and modification of code.

- **Rich Command Set**: The interpreter offers a wide range of commands for program flow control (`IF...THEN...ELSE`, `FOR...NEXT`, `DO...LOOP`), data manipulation, and hardware interfacing.

- **Data Types and Variables**: Supports floating-point numbers, 64-bit integers, and strings. Variables can have names up to 32 characters long, and arrays can have up to eight dimensions, limited only by available memory.

- **Extended Features**:
  - **File I/O**: Manage files on SD cards with FAT16 or FAT32 file systems up to 32GB. Perform sequential or random access, create directories, and handle long file names.
  - **Display Support**: Interface with LCD, OLED, and e-Ink display panels ranging from 0.96" to 9" with resolutions up to 640x480 pixels. Includes support for multiple fonts, image loading, and extensive graphics commands.
  - **Touch Interface**: Support for touch-sensitive LCD panels, enabling the creation of graphical user interfaces with on-screen buttons, switches, and keypads.
  - **Real-Time Clock**: Integrate with chips like PCF8563, DS1307, DS3231, or DS3232 to maintain accurate time.
  - **Sensor Integration**: Read data from sensors such as DS18B20 (temperature), DHT22/DH11 (temperature and humidity), and HC-SR04 (ultrasonic distance measurement).
  - **Communication Protocols**: Utilize protocols like I²C, SPI, and 1-Wire for sensor data acquisition and device control.

## Getting Started

To begin using MPBasic:

1. **Installation**: Clone the repository and follow the setup instructions provided in the documentation.
2. **Documentation**: Comprehensive guides and examples are available to help you get acquainted with the interpreter's capabilities and features.
3. **Community Support**: Join our community forums to seek assistance, share projects, and collaborate with other MPBasic users.

## Contributing

We welcome contributions from the community. If you're interested in contributing to MPBasic:

- **Reporting Issues**: Use the issue tracker to report bugs or suggest enhancements.
- **Submitting Pull Requests**: Fork the repository, make your changes, and submit a pull request for review.
- **Documentation**: Enhancements to documentation are always appreciated. Feel free to suggest changes or add new content.

## License

MPBasic is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Acknowledgments

Special thanks to the contributors and the open-source community for their support and collaboration in making MPBasic a robust and versatile tool for microcontroller programming.

---

*Note: This README provides an overview of MPBasic's capabilities and features. For detailed information, please refer to the official documentation and user guides.*
