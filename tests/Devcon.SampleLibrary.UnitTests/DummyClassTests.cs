using System;
using Xunit;

namespace Devcon.SampleLibrary.UnitTests
{
    public class DummyClassTests
    {
        [Fact]
        public void DummyTest1()
        {
            Assert.Equal(1, 1);
        }

        [Fact]
        public void DummyTest2()
        {
            Assert.Equal(1, 1);
        }

        [Fact]
        public void DummyClass_IsOdd_ShouldReturnTrueWhenOddNumber()
        {
            // Arrange
            var dummyClass = new DummyClass();

            // Act
            var result = dummyClass.IsOdd(13);

            // Assert
            Assert.True(result);
        }
    }
}
