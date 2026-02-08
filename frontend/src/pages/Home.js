import React from 'react';

function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-r from-blue-600 to-blue-800 text-white">
      <header className="px-6 py-4">
        <h1 className="text-4xl font-bold">EAGLEWINGS BANK</h1>
      </header>

      <main className="container mx-auto px-6 py-12">
        <section className="text-center mb-12">
          <h2 className="text-5xl font-bold mb-4">Welcome to Your Digital Bank</h2>
          <p className="text-xl opacity-90">Modern banking experience powered by cloud technology</p>
        </section>

        <section className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-12">
          <div className="bg-white bg-opacity-10 p-8 rounded-lg backdrop-blur-md">
            <h3 className="text-2xl font-bold mb-4">💳 Accounts</h3>
            <p>Manage multiple accounts with ease. Create saving and checking accounts.</p>
          </div>
          <div className="bg-white bg-opacity-10 p-8 rounded-lg backdrop-blur-md">
            <h3 className="text-2xl font-bold mb-4">💰 Transactions</h3>
            <p>Transfer money between accounts instantly with zero fees.</p>
          </div>
          <div className="bg-white bg-opacity-10 p-8 rounded-lg backdrop-blur-md">
            <h3 className="text-2xl font-bold mb-4">📊 Analytics</h3>
            <p>View detailed reports and analytics about your financial activity.</p>
          </div>
        </section>

        <div className="mt-12 text-center">
          <button className="bg-white text-blue-600 px-8 py-3 rounded-lg font-bold text-lg hover:bg-gray-100 transition">
            Get Started
          </button>
        </div>
      </main>
    </div>
  );
}

export default Home;
