# 🐾 SplitIt

A cross-platform split bill application for people to split and calculate bills or receipts.

## ✨ Features

- 📸 Easily scan your bills or receipts
- ✏️ Edit your scanable bills
- 👥 Add people to your bills
- 🧮 Distribute and calculate the bills with your group in a ratio manner
- 📱 Support for both iPhone and Android

## 📸 Screenshots

<div align="center">
  <img src="petstagram/screenshots/screen1.png" width="200" alt="Home Screen"/>
  <img src="petstagram/screenshots/screen2.png" width="200" alt="Profile Screen"/>
  <img src="petstagram/screenshots/screen3.png" width="200" alt="Profile Post Screen"/>
</div>

<div align="center">
  <img src="petstagram/screenshots/screen4.png" width="200" alt="Edit Profile"/>
  <img src="petstagram/screenshots/screen5.png" width="200" alt="Comment Screen"/>
  <img src="petstagram/screenshots/screen6.png" width="200" alt="Add Post Screen"/>
</div>

## 🛠 Technologies Used

- 🎯 Flutter Framework
- 🏗 Bloc
- 🧹 Clean Architecture
- 🌐 OCR by Google ML Kit for text recognition
- ⚡️ Mockito and mocktail for testing

## 📁 Project Structure

```
split_it/
├── assets/
├── coverage/
├── lib/
    ├── Core/
    ├── Data/
        ├── datasources/
        ├── mapper/
        ├── repository/
    ├── Domain/
        ├── repository/
        ├── usecase/
        ├── interactor/
        ├── models/
    ├── Presentation/
        ├── feature/
            ├── bloc/
            ├── views/
    ├── Resource/
        ├── Theme/
        ├── utils/
        ├── widgets/
└── test/
    ├── datasources/
    ├── homepage/
    ├── mapper/
    ├── Presentation/
    ├── mocks/
    ├── network/
    ├── repository/
    ├── scan_page/
    ├── split_bill/
    ├── summary_page/
```

## 🚀 How to Run

1. 📥 Clone this repository
2. 💻 Open `slit_it` folder in code editing software
3. 🔥 Create and configure your openrouter account
4. 💻 Create api key for `gemma-3-12b-it:free` model
5. ⚙️ Add `.env` to the project directory
   ```
    OPENAI_API_KEY: your_api_key
   ```
6. 📱 Select simulator or device target
7. ▶️ Run the project

## 🤝 Contributing

Please feel free to submit pull requests. For major changes, please open an issue first to discuss what you would like to change.

## 🙏 Credits

- UI Design by [Anin Arafath](https://www.figma.com/files/team/960855959145187195/resources/community/file/1515444362212782565?fuid=960855949645992227) - Amazing UI kit for split bill applications

## 📄 License

[MIT](https://choosealicense.com/licenses/mit/) 
