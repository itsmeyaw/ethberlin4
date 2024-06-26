import type { Metadata } from "next";
import { Inter, Press_Start_2P } from "next/font/google";
import "./globals.css";
import Providers from "@/app/providers";
import { Theme } from "@radix-ui/themes";
import classNames from "classnames";
import "@radix-ui/themes/styles.css";
import BottomNavigator from "@/components/BottomNavigator";
import { Toaster } from "react-hot-toast";
import Header from "@/components/Header";

const inter = Inter({ subsets: ["latin"] });
const press = Press_Start_2P({
  subsets: ["latin"],
  weight: ["400"],
  variable: "--font-space",
});

export const metadata: Metadata = {
  title: "BlockWhisper",
  description: "Generated by create next app",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={classNames(press.variable, "flex justify-center")}>
        <Theme
          accentColor={"purple"}
          panelBackground={"translucent"}
          appearance={"dark"}
          className={"w-full max-w-xl"}
        >
          <Providers>
            <Toaster />
            <div className={"text-white overflow-x-hidden min-h-screen"}>
              <Header /> {/* Use the Header component here */}
              {children}
            </div>
            <BottomNavigator />
          </Providers>
        </Theme>
      </body>
    </html>
  );
}
